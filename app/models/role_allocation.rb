class RoleAllocation < ActiveRecord::Base
  belongs_to :worklog_task
  belongs_to :user
  belongs_to :role
  
  scope :for_worklog_task, lambda {|task| where("worklog_task_id = ?", task.id) }
  scope :for_user, lambda {|user| where("user_id = ?", user.id)}
  
  scope :between, lambda {|start_date, end_date|
    where('start_date >= ? and end_date <= ?', start_date, end_date)
  }

  scope :start_date, lambda {|d|
    where('start_date <= ?', d).order("start_date DESC")
  }
  
  validates_presence_of :start_date, :user_id, :worklog_task_id, :role_id
  validate :positive_date_range?
  validate :no_overlapping_periods_for_same_user?

  def positive_date_range?
    if self.start_date > self.adjusted_end_date
      errors.add(:base, "End date must be >= start date!")
    end
  end
  
  def no_overlapping_periods_for_same_user?
    role_allocations = RoleAllocation.for_user(self.user).for_worklog_task(self.worklog_task).order("start_date")
    role_allocations.each do |role_allocation|
      next if role_allocation.id == self.id
      if overlaps_with(role_allocation.start_date, role_allocation.adjusted_end_date)
        errors.add(:base, "Role allocation is overlapping with already existing timerole_allocation for user! (start_date: #{role_allocation.start_date}, end_date: #{role_allocation.adjusted_end_date})")
      end
    end
  end
  
  def adjusted_end_date
    ongoing ? Date.today : self.end_date
  end
  
  def ongoing
    self.end_date.nil? 
  end
  
  def ongoing=(flag)
    self.end_date = nil if flag
  end

  def overlaps_with(range_start, range_end)
    is_before = (self.start_date < range_start.to_date and self.adjusted_end_date < range_start.to_date)
    is_after  = (self.start_date > range_end.to_date and self.adjusted_end_date > range_end.to_date)
    not (is_before or is_after)
  end
  
end
