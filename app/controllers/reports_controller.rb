class ReportsController < ApplicationController

  layout "reports"
  
  HOURS_IN_WORKDAY = 8.0
  DAYS_IN_MONTH = 30.5
  
  def utilization_summary
    @time_period_types = ["Year to date", "Quarter to date", "Month to date", "Custom period"]
    @selected_time_period_type = params[:time_period_type]
    case @selected_time_period_type
    when "Year to date"
      @end_date = Date.today
      @start_date = Date.new(@end_date.year, 1, 1)
    when "Quarter to date"
      @end_date = Date.today
      m = @end_date.month
      quarter_start_month = m % 3 == 0 ? m : m - (m % 3)
      @start_date = Date.new(@end_date.year, quarter_start_month, 1)
    when "Month to date"
      @end_date = Date.today
      @start_date = Date.new(@end_date.year, @end_date, 1)
    when "Custom period"
      @start_date = params[:start_date].nil? ? nil : Time.parse(params[:start_date]).to_date
      @end_date = params[:end_date].nil? ? nil : Time.parse(params[:end_date]).to_date
    end
    
    @worklog_task_types = ["All external", "Custom selection"]
    @selected_worklog_task_type = params[:worklog_task_type]
    
    @worklog_tasks = []
    if @start_date != nil and @end_date != nil
      @worklog_tasks = WorkPeriod.distinct_worklog_task_ids.
        between(@start_date, @end_date).map {|x| WorklogTask.find(x.worklog_task_id) }
      # filter out jrbh
      jrbh_ids = Company.jrbh_companies.map {|x| x.id}
      @worklog_tasks = @worklog_tasks.reject {|x| jrbh_ids.include? x.company.id}
      # sort by company name and then task name
      @worklog_tasks = @worklog_tasks.sort do |x, y|
        name_rank = x.company.name <=> y.company.name
        name_rank == 0 ? x.name <=> y.name : name_rank
      end
      @selected_worklog_tasks = Hash.new
      @num_selected_tasks = 0
      @worklog_tasks.each do |task|
        value = if @selected_worklog_task_type == "All external"
          "1"
        else
          params["worklog_task_#{task.id}"]
        end
        if value.nil?
          @selected_worklog_tasks[task.id] = false
        else
          @num_selected_tasks += 1
          @selected_worklog_tasks[task.id] = true
        end
      end
    end
    
    @generate_output = false
    
    if @start_date != nil and @end_date != nil and @num_selected_tasks != 0
      begin
        # make worklog tasks only include the selected tasks
        @worklog_tasks = @worklog_tasks.select {|task| @selected_worklog_tasks[task.id] }
        
        @users = []
        @worklog_tasks.each do |task|
          task_users = WorkPeriod.distinct_user_ids.worklog_task(task.name).between(@start_date, @end_date).map {|x| User.find(x.user_id) }
          @users = @users.concat(task_users)
        end
        @users.uniq!
        @users.sort! {|x,y| x.alias <=> y.alias }
        
        generate_data_for_utilization_tables()
        
        generate_role_allocations()
        
        @generate_output = true
      rescue DataGenerationError => e
        flash.now[:error] = e.to_s
      end
    end
    
    respond_to do |format|
      format.html
    end
  end

  def individual_summary
  end

  def company_summary
  end

  private
  
  class DataGenerationError < StandardError
  end
  
  class UtilizationStats < Struct.new(:hours_logged,
    :days_logged,
    :hours_planned,
    :days_planned,
    :logged_over_planned_pcnt,
    :value_at_project_rate_card,
    :value_at_standard_rate_card)
  end
  
  class RoleAllocationEntry < Struct.new(:start_date, :end_date, :role)
  end
  
  def generate_data_for_utilization_tables()
    @user_stats = Hash.new
    @role_stats = Hash.new
    
    @total_hours_logged = 0
    @total_days_logged = 0
    @total_hours_planned = 0
    @total_days_planned = 0
    @total_value_at_project_rate_card = 0
    @total_value_at_standard_rate_card = 0
    
    @users.each do |user|
      
      calculate_work_time(user)
      @total_hours_logged += @user_stats[user].hours_logged
      @total_days_logged += @user_stats[user].days_logged
      
      calculate_planned_work_time(user)
      @user_stats[user].hours_planned ||= 0
      @user_stats[user].days_planned ||= 0
      @total_hours_planned += @user_stats[user].hours_planned
      @total_days_planned += @user_stats[user].days_planned
      
      calculate_value_of_time(user)
      @user_stats[user].value_at_project_rate_card ||= 0
      @user_stats[user].value_at_standard_rate_card ||= 0
      @total_value_at_project_rate_card += @user_stats[user].value_at_project_rate_card
      @total_value_at_standard_rate_card += @user_stats[user].value_at_standard_rate_card
      
      @user_stats[user].logged_over_planned_pcnt = if @user_stats[user].hours_planned == 0
        "N/A"
      else
        ratio = (@user_stats[user].hours_logged.to_f / @user_stats[user].hours_planned.to_f) * 100.0
        "#{ratio.round(0).to_i} %"
      end
    end
    
    @total_logged_over_planned_pcnt = if @total_hours_planned == 0
      "N/A"
    else
      ratio = (@total_hours_logged.to_f / @total_hours_planned.to_f) * 100.0
      "#{ratio.round(0).to_i} %"
    end
    
    @role_stats.each do |role, stats|
      stats.logged_over_planned_pcnt = if stats.hours_planned == 0
        "N/A"
      else
        ratio = (stats.hours_logged.to_f / stats.hours_planned.to_f) * 100.0
        "#{ratio.round(0).to_i} %"
      end
    end
    
    @roles = @role_stats.keys
    
    true
  end

  def calculate_work_time(user)
    @worklog_tasks.each do |task|
      periods = WorkPeriod.user(user.alias).worklog_task(task.name).between(@start_date, @end_date)
      periods.each do |x|
        @user_stats[user] ||= UtilizationStats.new
        role = role_for_user(user, task, x.start)
        @role_stats[role] ||= UtilizationStats.new

        @user_stats[user].hours_logged ||= 0
        @role_stats[role].hours_logged ||= 0
        @user_stats[user].days_logged ||= 0
        @role_stats[role].days_logged ||= 0

        value = (x.duration / 1.hour)
        @user_stats[user].hours_logged += value
        @role_stats[role].hours_logged += value
        
        value = value / HOURS_IN_WORKDAY
        @user_stats[user].days_logged += value
        @role_stats[role].days_logged += value
      end
    end
  end
  
  def calculate_planned_work_time(user)
    @worklog_tasks.each do |task|
      timeplans = Timeplan.for_user(user).for_worklog_task(task)
      timeplans.each do |timeplan|
        # in current period?
        next unless timeplan.overlaps_with(@start_date, @end_date)

        # start of overlap is the later of the two start dates
        overlap_start_date = @start_date >= timeplan.start_date ? @start_date : timeplan.start_date
        # end of overlap is the earlier of the two end dates
        overlap_end_date = @end_date <= timeplan.adjusted_end_date ? @end_date : timeplan.adjusted_end_date
        overlap_in_days = ((overlap_end_date - overlap_start_date) + 1.0).to_f
        
        planned_allocation = case timeplan.allocation_type
        when "Total"
          # proportional to how big overlap is compared to total
          timeplan.time_allocation * overlap_in_days / timeplan.duration_in_days          
        when "Monthly"
          # proportional to how many months the overlap is
          timeplan.time_allocation * overlap_in_days / DAYS_IN_MONTH
        else
          raise "Unknown allocation type found!"
        end

        role = role_for_user(user, task, overlap_start_date)
        
        @user_stats[user] ||= UtilizationStats.new
        @user_stats[user].days_planned ||= 0
        @user_stats[user].hours_planned ||= 0
        
        @role_stats[role] ||= UtilizationStats.new
        @role_stats[role].days_planned ||= 0
        @role_stats[role].hours_planned ||= 0
        
        @user_stats[user].days_planned += planned_allocation
        @user_stats[user].hours_planned += planned_allocation * HOURS_IN_WORKDAY

        @role_stats[role].days_planned += planned_allocation
        @role_stats[role].hours_planned += planned_allocation * HOURS_IN_WORKDAY
      end
    end
    true
  end

  def calculate_value_of_time(user)
    @worklog_tasks.each do |task|
      WorkPeriod.user(user.alias).worklog_task(task.name).each do |wp|
        next unless wp.overlaps_with(@start_date, @end_date)
        
        # start of overlap is the later of the two start dates
        overlap_start = @start_date.to_time >= wp.start ? @start_date.to_time : wp.start
        # end of overlap is the earlier of the two end dates
        overlap_end = @end_date.to_time <= wp.end ? @end_date.to_time : wp.end
        
        overlap_in_days = ((overlap_end - overlap_start) + 1.0).to_f / HOURS_IN_WORKDAY.hours
        
        role = role_for_user(user, task, overlap_start)

        @user_stats[user] ||= UtilizationStats.new
        @role_stats[role] ||= UtilizationStats.new
        
        @user_stats[user].value_at_project_rate_card ||= 0
        @user_stats[user].value_at_standard_rate_card ||= 0
        @role_stats[role].value_at_project_rate_card ||= 0
        @role_stats[role].value_at_standard_rate_card ||= 0
        
        # project rate
        br_query = BillingRate.for_role(role).for_worklog_task(task).start_date(overlap_start)
        if br_query.size == 0
          raise DataGenerationError.new("No project billing rate defined at time #{overlap_start},company '#{task.company.name}', task '#{task.name}' for role #{role.name}. Please add!")
        end
        project_rate = br_query.first
        value = project_rate.rate * overlap_in_days
        @user_stats[user].value_at_project_rate_card += value 
        @role_stats[role].value_at_project_rate_card += value
        
        # standard rate
        br_query = BillingRate.for_role(role).for_worklog_task(WorklogTask.standard_rate_card).start_date(overlap_start)
        if br_query.size == 0
          raise DataGenerationError.new("No standard billing rate defined at time #{overlap_start} for role #{role.name}. Please add!")
        end
        standard_rate = br_query.first
        value = standard_rate.rate * overlap_in_days
        @user_stats[user].value_at_standard_rate_card += value
        @role_stats[role].value_at_standard_rate_card += value
      end
    end
    true
  end

  def role_for_user(user, task, d)
    # figure out role
    role_query = RoleAllocation.for_user(user).for_worklog_task(task).start_date(d.to_date)
    if role_query.size == 0
      raise DataGenerationError.new("No roles defined at time #{d}, company '#{task.company.name}', task '#{task.name}' for user #{user.alias}. Please add!")
    end
    role_query.first.role
  end
  
  def generate_role_allocations()
    @role_allocations = Hash.new
    @worklog_tasks.each do |task|
      RoleAllocation.for_worklog_task(task).each do |role_alloc|
        next unless role_alloc.overlaps_with(@start_date, @end_date)
        
        overlap_start_date = @start_date >= role_alloc.start_date ? @start_date : role_alloc.start_date
        overlap_end_date = @end_date <= role_alloc.adjusted_end_date ? @end_date : role_alloc.adjusted_end_date
        
        @role_allocations[role_alloc.user] ||= []
        @role_allocations[role_alloc.user] << RoleAllocationEntry.new(overlap_start_date, overlap_end_date, role_alloc.role)
      end
    end
  end
  
end
