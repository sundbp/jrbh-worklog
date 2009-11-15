class WorkPeriod < ActiveRecord::Base
  belongs_to :user
  belongs_to :worklog_task

  def company
    worklog_task.company
  end
end
