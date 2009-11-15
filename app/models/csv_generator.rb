class CsvGenerator
  attr_accessor :start_date, :end_date, :users, :companies, :worklog_tasks, :company_or_task

  def initialize
    @start_date = Date.today
    @end_date = Date.today
    @users = @companies = @worklog_tasks = Array.new
    @company_or_task = "company"
  end
end
