class Company < ActiveRecord::Base
  has_many :worklog_tasks, :dependent => :destroy
  has_many :work_periods, :through => :worklog_tasks
end
