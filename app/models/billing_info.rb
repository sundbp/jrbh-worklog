class BillingInfo < ActiveRecord::Base
  belongs_to :worklog_task
  
  scope :for_worklog_task, lambda {|task| where("worklog_task_id = ?", task.id) }
  
  validates_presence_of :start_date, :worklog_task_id
  validates_numericality_of :invoice_amount
  validate :positive_date_range?
  
  def positive_date_range?
    if self.start_date > self.end_date
      errors.add(:base, "End date must be >= start date!")
    end
  end

end
