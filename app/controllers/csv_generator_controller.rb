require 'csv'

class CsvGeneratorController < ApplicationController
  before_filter :require_user

  layout "csv_generator"
  
  def by_company_form
    @csv_generator = CsvGenerator.new
    @csv_generator.company_or_task = "company"
    @users = User.order("alias")
    @companies = Company.order("name")
  end

  def by_task_form
    @csv_generator = CsvGenerator.new
    @csv_generator.company_or_task = "task"
    @users = User.order("alias")
    @companies = Company.order("name")
    @worklog_tasks_by_company = WorklogTask.order("name").inject(Hash.new) do |result, task|
      result[task.company.name] ||= []
      result[task.company.name] << task
      result
    end
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
      wps = case params[:csv_generator][:company_or_task]
        when "company"
          company_or_task = :company
          WorkPeriod.joins(:worklog_task => :company).
            where(:user_id => params[:csv_generator][:users]).
            where(:worklog_task => {:company_id => params[:csv_generator][:companies]}).
            where(:start.gte => start_date, :end.lte => end_date)
        when "task"
          company_or_task = :task
          WorkPeriod.joins(:worklog_task => :company).
            where(:user_id => params[:csv_generator][:users]).
            where(:worklog_task_id => params[:csv_generator][:worklog_tasks]).
            where(:start.gte => start_date, :end.lte => end_date)
        else
          raise "company or task is neither company or task!"
      end
      
      csv_string = CSV.generate do |csv|
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
