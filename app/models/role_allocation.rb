class RoleAllocation < ActiveRecord::Base
  belongs_to :worklog_task
  belongs_to :user
  
  scope :for_worklog_task, lambda {|task| where("worklog_task_id = ?", task.id) }
  scope :for_user, lambda {|user| where("user_id = ?", user.id)}
  
  validates_presence_of :start_date, :role, :user_id, :worklog_task_id
  validate :positive_date_range?
  validate :no_overlapping_periods_for_same_user?

  def self.available_roles
    ["Director", "Project Manager", "Senior Consultant", "Consultant", "Analyst"]
  end

  def positive_date_range?
    if self.start_date > self.adjusted_end_date
      errors.add(:base, "End date must be >= start date!")
    end
  end
  
  def no_overlapping_periods_for_same_user?
    role_allocations = RoleAllocation.for_user(self.user).for_worklog_task(self.worklog_task).order("start_date")
    role_allocations.each do |role_allocation|
      next if role_allocation.id == self.id
      is_before = self.start_date < role_allocation.start_date and self.adjusted_end_date < role_allocation.start_date
      is_after  = self.start_date > role_allocation.adjusted_end_date and self.adjusted_end_date > role_allocation.adjusted_end_date
      if not (is_before or is_after)
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

end
