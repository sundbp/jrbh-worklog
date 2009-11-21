class CsvGeneratorController < ApplicationController
  before_filter :require_user

  layout "csv_generator"
  
  def by_company_form
    @csv_generator = CsvGenerator.new
    @csv_generator.company_or_task = "company"
  end

  def by_task_form
    @csv_generator = CsvGenerator.new
    @csv_generator.company_or_task = "task"
  end
  
  def show
    params[:csv_generator][:users] ||= []
    params[:csv_generator][:companies] ||= []
    params[:csv_generator][:worklog_tasks] ||= []

    start_date = nil
    end_date = nil
    success = true
    begin
      start_date = Date.new(params[:csv_generator][:"start_date(1i)"].to_i,params[:csv_generator][:"start_date(2i)"].to_i,params[:csv_generator][:"start_date(3i)"].to_i)
      end_date = Date.new(params[:csv_generator][:"end_date(1i)"].to_i,params[:csv_generator][:"end_date(2i)"].to_i,params[:csv_generator][:"end_date(3i)"].to_i) + 1
    rescue
      success = false
    end

    if success
      company_or_task = nil
      conditions = case params[:csv_generator][:company_or_task]
        when "company"
          company_or_task = :company
          ["work_periods.user_id IN (?) and companies.id IN (?) and work_periods.start >= ? and work_periods.end <= ?",
           params[:csv_generator][:users],
           params[:csv_generator][:companies],
           start_date,
           end_date
          ]
        when "task"
          company_or_task = :task
          ["work_periods.user_id IN (?) and work_periods.worklog_task_id IN (?) and work_periods.start >= ? and work_periods.end <= ?",
           params[:csv_generator][:users],
           params[:csv_generator][:worklog_tasks],
           start_date,
           end_date
          ]
        else
          raise "company or task is neither company or task!"
      end
      wps = WorkPeriod.find(:all,
                            :joins => "as work_periods inner join worklog_tasks on work_periods.worklog_task_id = worklog_tasks.id inner join companies on worklog_tasks.company_id = companies.id",
                            :conditions => conditions,
                            :order => "work_periods.user_id, companies.id, work_periods.worklog_task_id, work_periods.start")

      csv_string = FasterCSV.generate do |csv|
        if company_or_task == :company
          csv << ["user", "company", "start", "end", "duration_in_hours"]
        else
          csv << ["user", "company", "worklog_task", "start", "end", "duration_in_hours"]
        end
        wps.each do |wp|
          if company_or_task == :company
            csv << [wp.user.alias, wp.company.name, wp.start, wp.end, (wp.end - wp.start).to_f/1.hour.to_f]
          else
            csv << [wp.user.alias, wp.company.name, wp.worklog_task.name, wp.start, wp.end, (wp.end - wp.start).to_f/1.hour.to_f]
          end
        end
      end
      send_data csv_string, :type => "text/csv", :filename => "worklog_data.csv", :disposition => 'attachment'
    else
      respond_to do |format|
        flash[:error] = "Bad date(s) entered, please check"
        format.html { redirect_to :back }
      end
    end
    
  end

  def big_header
    "CSV Generator"
  end
end
