#!/usr/bin/env ruby

users = User.find(:all)

users.each do |u|
  periods = u.work_periods.sort {|a,b| a.start <=> b.start}
  prev = nil
  cumm = []
  active_chain = false
  periods.each do |p|
    unless prev
      prev = p
      next
    end
    p p
    if (prev.worklog_task_id == p.worklog_task_id) and (prev.end == p.start)
      # add period ot the chain
      cumm << prev if cumm == []
      cumm << p
      active_chain = true
    elsif active_chain
      # chain is over, flatten the cumm entries with one entry
      start_t = cumm.first.start
      end_t = cumm.last.end
      comment = ((cumm.select {|x| x.comment != nil and x.comment != ""}).map {|x| x.comment }).join(", ")
      p comment
      # create new entry
      WorkPeriod.create(:user_id => u.id,
                        :worklog_task_id => cumm.first.worklog_task_id,
                        :start => start_t,
                        :end => end_t,
                        :comment => comment)

      # remove old entries
      cumm.each { |x| x.destroy }

      # reset chain info
      active_chain = false
      cumm = []
    end

    prev = p
  end

  if cumm != []
    # chain is over, flatten the cumm entries with one entry
    start_t = cumm.first.start
    end_t = cumm.last.end
    comment = ((cumm.select {|x| x.comment != nil and x.comment != ""}).map {|x| x.comment }).join(", ")
    p comment
    # create new entry
    WorkPeriod.create(:user_id => u.id,
                      :worklog_task_id => cumm.first.worklog_task_id,
                      :start => start_t,
                      :end => end_t,
                      :comment => comment)

    # remove old entries
    cumm.each { |x| x.destroy }
  end
end