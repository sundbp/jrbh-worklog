class BillingRate < ActiveRecord::Base
  belongs_to :worklog_task
  belongs_to :role
  
  scope :for_worklog_task, lambda {|task| where("worklog_task_id = ?", task.id) }
  scope :for_role, lambda {|role| where("role_id = ?", role.id) }
  
  validates_presence_of :start_date, :role_id, :worklog_task_id
  validates_numericality_of :rate, :greather_than => 0
  validate :positive_date_range?
  validate :no_overlapping_periods_for_same_user?

  def positive_date_range?
    if self.start_date > self.adjusted_end_date
      errors.add(:base, "End date must be >= start date!")
    end
  end
  
  def no_overlapping_periods_for_same_user?
    billing_rates = BillingRate.for_role(self.role).for_worklog_task(self.worklog_task).order("start_date")
    billing_rates.each do |billing_rate|
      next if billing_rate.id == self.id
      is_before = self.start_date < billing_rate.start_date and self.adjusted_end_date < billing_rate.start_date
      is_after  = self.start_date > billing_rate.adjusted_end_date and self.adjusted_end_date > billing_rate.adjusted_end_date
      if not (is_before or is_after)
        errors.add(:base, "Role allocation is overlapping with already existing timebilling_rate for user! (start_date: #{billing_rate.start_date}, end_date: #{billing_rate.adjusted_end_date})")
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
