class DatabaseCheckMailer < ActionMailer::Base

  MIN_PERIOD_LENGTH = 30.minutes
  MAX_PERIOD_LENGTH = 15.hours
  UNUSUALLY_LONG_PERIOD_LENGTH = 10.hours

  def self.overlaps?(wp1, wp2)
    not (wp1["start"] > (wp2["end"]-1.second) or wp1["end"] < (wp2["start"]+1.second))
  end
  
  def self.run_consistency_check

    # find all pairwise overlaps
    overlaps = []
    User.find(:all).each do |user|
      wps = WorkPeriod.user(user.alias)
      (0..wps.size-2).each do |i|
        overlaps << [wps[i], wps[i+1]] if overlaps?(wps[i], wps[i+1])
      end
    end

    # find all periods that are too short or too long
    short_periods = []
    long_periods = []
    WorkPeriod.find(:all).each do |wp|
      if wp.duration < MIN_PERIOD_LENGTH
        short_periods << wp
      elsif wp.duration >= MAX_PERIOD_LENGTH
        long_periods << wp
      end
    end

    # find periods that don't have valid user or task
    no_user = []
    no_task = []
    no_company = []
    WorkPeriod.find(:all).each do |wp|
      no_user << wp if wp.user.nil?
      no_task << wp if wp.worklog_task.nil?
      no_company << wp if wp.company.nil?
    end

    send_email = [overlaps, short_periods, long_periods, no_user, no_task, no_company].inject(0) {|sum, x| sum + x.size}
    DatabaseCheckMailer.deliver_consistency(overlaps, short_periods, long_periods, no_user, no_task, no_company) if send_email != 0
  end

  def self.run_nagging_check
    User.active_employees.each do |user|
      latest_wp = user.work_periods.first
      c_time = Time.now
      if c_time - latest_wp.end > APP_CONFIG['num_days_to_start_nag'].days
        DatabaseCheckMailer.deliver_nagging(user, latest_wp, c_time)
      end
    end
  end

  def self.run_gap_check
    User.active_employees.each do |user|
      wps = WorkPeriod.user(user.alias).last_days(APP_CONFIG['num_days_to_check_gaps']).reverse
      gaps = []
      (0..wps.size-2).each do |i|
          wp1 = wps[i]
          wp2 = wps[i+1]
          if (wp1.end.wday == wp2.start.wday) and
                  (wp2.start - wp1.end >= APP_CONFIG['num_hours_is_gap'].hours) and
                  wp2.start.hour <= APP_CONFIG['gap_cutoff_hour']
            
            gaps << [wp1, wp2]
          end
      end
      if gaps.size != 0
        DatabaseCheckMailer.deliver_gap_warning(user, gaps)
      end
    end
  end

  def self.run_unusually_long_periods_check
    User.active_employees.each do |user|
      wps = WorkPeriod.user(user.alias).last_days(APP_CONFIG['num_days_to_check_gaps']).reverse
      unusually_long = wps.select {|wp| wp.duration > UNUSUALLY_LONG_PERIOD_LENGTH }
      if  unusually_long.size != 0
        DatabaseCheckMailer.deliver_unusually_long_period_warning(user, unusually_long)
      end
    end
  end

  def consistency(overlaps, short_periods, long_periods, no_user, no_task, no_company, sent_at = Time.now)
    subject    'Worklog - Database consistency check failed'
    recipients APP_CONFIG['worklog_email_to']
    from       APP_CONFIG['worklog_email_from']
    sent_on    sent_at
    content_type 'text/html'
    
    body       :overlaps => overlaps,
               :short_periods => short_periods,
               :long_periods => long_periods,
               :no_user => no_user,
               :no_task => no_task,
               :no_company => no_company
  end

  def nagging(user, latest_wp, sent_at = Time.now)
    email = if user.email.nil?
      APP_CONFIG['email_failover_address']
    else
      user.email
    end
    subject    'Worklog - Nag nag nag!'
    recipients email
    from       APP_CONFIG['worklog_email_from']
    sent_on    sent_at
    content_type 'text/html'
    body       :user => user,
               :latest_wp => latest_wp,
               :c_time => sent_on
  end

  def gap_warning(user, gaps, sent_at = Time.now)
    email = if user.email.nil?
      APP_CONFIG['email_failover_address']
    else
      user.email
    end
    subject    'Worklog - Suspicious gap found'
    recipients email
    from       APP_CONFIG['worklog_email_from']
    sent_on    sent_at
    content_type 'text/html'
    
    body       :user => user,
               :gaps => gaps
  end

  def unusually_long_period_warning(user, unusually_long, sent_at = Time.now)
    email = if user.email.nil?
      APP_CONFIG['email_failover_address']
    else
      user.email
    end
    subject    'Worklog - Suspiciously long period(s) found'
    recipients email
    from       APP_CONFIG['worklog_email_from']
    sent_on    sent_at
    content_type 'text/html'
    body       :user => user,
               :unusually_long => unusually_long
  end

end
