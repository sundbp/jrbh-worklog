class WorkPeriod < ActiveRecord::Base
  belongs_to :user
  belongs_to :worklog_task

  validate :correct_period?

  scope :between, lambda { |start_t, end_t|
    where('start >= ? and work_periods.end <= ?', start_t, end_t)
  }
  
  scope :last_days, lambda { |num_days|
    where('? - start <= ?', Time.now, "#{num_days} days")
  }

  scope :user, lambda { |user|
    joins(:user).where('users.id = ?', user.id)
  }

  scope :worklog_task, lambda { |task|
    joins(:worklog_task).where('worklog_tasks.id = ?', task.id)
  }

  scope :distinct_worklog_task_ids, lambda {
    group(:worklog_task_id).select(:worklog_task_id) 
  }
  
  scope :distinct_user_ids, lambda {
    group(:user_id).select(:user_id) 
  }

  scope :for_worklog_tasks, lambda {|tasks|
    joins(:worklog_task).where("worklog_tasks.id IN (?)", tasks)
  }
  
  scope :for_internal_companies, WorkPeriod.for_worklog_tasks(WorklogTask.internal_tasks)
  scope :for_internal_companies_work, WorkPeriod.for_worklog_tasks(WorklogTask.internal_tasks_work)
  scope :for_internal_companies_non_work, WorkPeriod.for_worklog_tasks(WorklogTask.internal_tasks_non_work)
  scope :holidays, WorkPeriod.for_worklog_tasks(WorklogTask.holidays)
  scope :sickness, WorkPeriod.for_worklog_tasks(WorklogTask.sickness)

  scope :for_external_companies, WorkPeriod.for_worklog_tasks(WorklogTask.external_tasks)
    
  def company
    worklog_task.company
  end

  def duration
    attributes['end']-start
  end
  
  def overlaps_with(range_start, range_end)
    is_before = (self.start < range_start and self.end < range_start)
    is_after  = (self.start > range_end and self.end > range_end)
    not (is_before or is_after)
  end

  private

  def correct_period?
    if start >= attributes['end']
      errors.add(:end, " is before (or equal) to start. Negative time does not exist!")
    elsif start.to_date != attributes['end'].to_date
      errors.add_to_base("start and end need to be on the same day, no spanning of midnight allowed!")
    else
      wp = WorkPeriod.where('user_id=? and not (start > ? or work_periods.end < ?)',
        user.id, 
        attributes['end']-1.second, 
        start+1.second
      ).first
      unless wp.nil? or wp.id == id
        errors.add_to_base("work period overlaps with existing entry!")
      end
    end
  end
end
