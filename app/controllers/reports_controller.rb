class ReportsController < ApplicationController

  layout "reports"
  
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
    
    if @start_date != nil and @end_date != nil and @num_selected_tasks != 0
      @generate_output = true
      generate_output_data()
    else
      @generate_output = false
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
  
  class UserStats < Struct.new(:total_hours, :total_days, :total_days_planned)
  end
  
  def generate_output_data()
    # make worklog tasks only include the selected tasks
    @worklog_tasks = @worklog_tasks.select {|task| @selected_worklog_tasks[task.id] }

    @users = []
    @worklog_tasks.each do |task|
      task_users = WorkPeriod.distinct_user_ids.worklog_task(task.name).between(@start_date, @end_date).map {|x| User.find(x.user_id) }
      @users = @users.concat(task_users)
    end
    @users.uniq!
    @users.sort! {|x,y| x.alias <=> y.alias }
    
    @user_stats = Hash.new
    
    @total_hours_logged = 0
    @total_days_logged = 0
    @total_days_planned = 0
      
    @users.each do |user|
      stats = UserStats.new

      total_seconds = calculate_work_time(user)
      stats.total_hours = total_seconds / 3600.0
      stats.total_days = stats.total_hours / 24.0
      @total_hours_logged += stats.total_hours
      @total_days_logged += stats.total_days
      
      stats.total_days_planned = calculate_planned_work_time(user)
      @total_days_planned += stats.total_days_planned
      
      @user_stats[user] = stats
    end
  end

  def calculate_work_time(user)
    total_seconds = 0    
    @worklog_tasks.each do |task|
      periods = WorkPeriod.user(user.alias).worklog_task(task.name).between(@start_date, @end_date)
      periods.each {|x| total_seconds += x.duration }
    end
    total_seconds
  end
  
  def calculate_planned_work_time(user)
    total_days = 0
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
          #p "------------------------------"
          #p "found a total timeplan for #{user.alias}"
          #p "overlap is #{overlap_start_date} - #{overlap_end_date}"
          #p "overlap length is #{overlap_in_days}"
          #p "total timeplan length is #{timeplan.duration_in_days}"
          #p "total time allocation: #{timeplan.time_allocation}"
          #p "% of total: #{overlap_in_days / timeplan.duration_in_days}"
          timeplan.time_allocation * overlap_in_days / timeplan.duration_in_days          
        when "Monthly"
          # proportional to how many months the overlap is
          #p "------------------------------"
          #p "found a monthly timeplan for #{user.alias}"
          #p "overlap is #{overlap_start_date} - #{overlap_end_date}"
          #p "overlap length is #{overlap_in_days}"
          #p "monthly time allocation: #{timeplan.time_allocation}"
          #p "num months: #{overlap_in_days / 30.5}"
          timeplan.time_allocation * overlap_in_days / 30.5
        else
          raise "Unknown allocation type found!"
        end
        #p "overlap length = #{planned_allocation}"
        total_days += planned_allocation
      end
    end
    total_days
  end
  
end
