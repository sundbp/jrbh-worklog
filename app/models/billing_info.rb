class BillingInfo < ActiveRecord::Base
  belongs_to :worklog_task
  
  scope :for_worklog_task, lambda {|task| where(:worklog_task => task) }

  scope :overlaps_with, lambda { |start_date, end_date|
    where(
      # contained in period
      {:start_date.gte => start_date, :end_date.lte => end_date} |
      # covers the period
      {:start_date.lte => start_date, :end_date.gte => end_date} |
      # partly covers period, start of it
      {:start_date.lte => start_date, :end_date.gte => start_date, :end_date.lte => end_date} |
      # partly covers period, end of it
      {:start_date.gte => start_date, :start_date.lte => end_date, :end_date.gte => end_date}
    )
  }
  
  validates_presence_of :start_date, :end_date, :worklog_task_id
  validates_numericality_of :invoice_amount
  validate :positive_date_range?
  
  def positive_date_range?
    if self.start_date > self.end_date
      errors.add(:base, "End date must be >= start date!")
    end
  end

end
