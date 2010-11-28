class Timeplan < ActiveRecord::Base
  belongs_to :worklog_task
  belongs_to :user
  
  scope :for_worklog_task, lambda {|task| where("worklog_task_id = ?", task.id) }
  scope :for_user, lambda {|user| where("user_id = ?", user.id)}
  
  validates_presence_of :start_date, :allocation_type, :user_id, :worklog_task_id
  validates_numericality_of :time_allocation, :greather_than => 0
  validate :positive_date_range?
  validate :no_overlapping_periods_for_same_user?
  
  def positive_date_range?
    if self.start_date > self.adjusted_end_date
      errors.add(:base, "End date must be >= start date!")
    end
  end
  
  def no_overlapping_periods_for_same_user?
    timeplans = Timeplan.for_user(self.user).for_worklog_task(self.worklog_task).order("start_date")
    timeplans.each do |plan|
      next if plan.id == self.id
      is_before = self.start_date < plan.start_date and self.adjusted_end_date < plan.start_date
      is_after  = self.start_date > plan.adjusted_end_date and self.adjusted_end_date > plan.adjusted_end_date
      if not (is_before or is_after)
        errors.add(:base, "Timeplan is overlapping with already existing timeplan for user! (start_date: #{plan.start_date}, end_date: #{plan.adjusted_end_date})")
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
