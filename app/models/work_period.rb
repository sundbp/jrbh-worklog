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
      else
        wp = WorkPeriod.find(:first, :conditions => ['user_id=? and not (start > ? or end < ?)',
                                                     user.id, start-1.second, attributes['end']+1.second])
        unless wp.nil?
          errors.add_to_base("work period overlaps with existing entry!")
        end
      end
    end
end
