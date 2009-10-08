class Company < ActiveRecord::Base
  has_many :worklog_tasks
end
