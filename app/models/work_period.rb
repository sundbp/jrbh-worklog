class WorkPeriod < ActiveRecord::Base
  belongs_to :user
  belongs_to :worklog_task

  validate :correct_period?

  def company
    worklog_task.company
  end

private
    def correct_period?
      if start >= attributes['end']
        errors.add(:end, " is before (or equal) to start. Negative time does not exist!")
      elsif start.to_date != attributes['end'].to_date
        errors.add_to_base("start and end need to be on the same day, no spanning of midnight allowed!")
      end
    end
end
