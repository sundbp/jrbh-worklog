class WorkPeriod < ActiveRecord::Base
  belongs_to :user
  belongs_to :worklog_task
end
