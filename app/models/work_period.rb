class WorkPeriod < ActiveRecord::Base
  belongs_to :user
  belongs_to :worklog_task

  validate :correct_period?

  default_scope :order => "start DESC"
  
  named_scope :between, lambda { |start_t, end_t|
    {
      :conditions => ['start >= ? and work_periods.end <= ?', start_t, end_t]
    }
  }
  named_scope :last_days, lambda { |num_days|
    {
      :conditions => ['? - start <= ?', Time.now, "#{num_days} days"]
    }
  }

  named_scope :user, lambda { |user_alias|
    {
      :joins => "as work_periods inner join users on users.id = work_periods.user_id",
      :conditions => ['users.alias = ?', user_alias]
    }
  }
  
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
        wp = WorkPeriod.find(:first, :conditions => ['user_id=? and not (start > ? or work_periods.end < ?)',
                                                     user.id, attributes['end']-1.second, start+1.second])
        unless wp.nil? or wp.id == id
          errors.add_to_base("work period overlaps with existing entry!")
        end
      end
    end
end
