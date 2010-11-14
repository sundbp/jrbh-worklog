class WorkPeriodsFlattener
  def self.flatten_work_periods
    User.all.each do |user|
      periods = WorkPeriod.user(user.alias).reverse
      prev = nil
      cumm = []
      active_chain = false
      periods.each do |p|
        unless prev
          prev = p
          next
        end
        if (prev.worklog_task_id == p.worklog_task_id) and (prev.end == p.start)
          # add period ot the chain
          cumm << prev if cumm == []
          cumm << p
          active_chain = true
        elsif active_chain
          # chain is over, flatten the cumm entries with one entry
          flatten_one(cumm, user)
          # reset chain info
          active_chain = false
          cumm = []
        end
        prev = p
      end
      if cumm != []
        flatten_one(cumm, user)
      end
    end
  end

  def self.flatten_one(cumm, user)
    if cumm != []
      # chain is over, flatten the cumm entries with one entry
      start_t = cumm.first.start
      end_t = cumm.last.end
      comment = ((cumm.select {|x| x.comment != nil and x.comment != ""}).map {|x| x.comment }).join(", ")
      if comment.size > 255
        comment = comment[0..254]
      end
      wltid = cumm.first.worklog_task_id
      ActiveRecord::Base.transaction do
        # remove old entries, need to remove these first since otherwise validation will fail on creation
        cumm.each {|x| x.destroy }

        # create new entry
        wp = WorkPeriod.create(:user_id => user.id,
                               :worklog_task_id => wltid,
                               :start => start_t,
                               :end => end_t,
                               :comment => comment)
        raise "Could not create condensed work period when flattening work periods!" if wp.nil?
      end
    end
  end
end
