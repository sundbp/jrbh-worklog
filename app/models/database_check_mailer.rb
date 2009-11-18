class DatabaseCheckMailer < ActionMailer::Base

  MIN_PERIOD_LENGTH = 30.minutes
  MAX_PERIOD_LENGTH = 10.hours

  def self.overlaps?(wp1, wp2)
    not (wp1["start"] > (wp2["end"]-1.second) or wp1["end"] < (wp2["start"]+1.second))
  end
  
  def self.run_consistency_check

    # find all pairwise overlaps
    overlaps = []
    User.find(:all).each do |user|
      wps = WorkPeriod.find(:all, :conditions => ["user_id = ?", user.id])
      (0..wps.size-1).each do |i|
        next if i == wps.size-1
        (i+1..wps.size-1).each do |j|
          wp1 = wps[i]
          wp2 = wps[j]
          next if wp1 == wp2
          if overlaps?(wp1,wp2)
            overlaps << [wp1, wp2]
          end
        end
      end
    end

    # find all periods that are too short or too long
    short_periods = []
    long_periods = []
    WorkPeriod.find(:all).each do |wp|
      if wp.end - wp.start <= MIN_PERIOD_LENGTH 
        short_periods << wp
      elsif wp.end - wp.start >= MAX_PERIOD_LENGTH
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

  end

  def consistency(overlaps, short_periods, long_periods, no_user, no_task, no_company, sent_at = Time.now)
    subject    'Worklog - Database consistency check failed'
    recipients APP_CONFIG['worklog_email_to']
    from       APP_CONFIG['worklog_email_from']
    sent_on    sent_at
    
    body       :overlaps => overlaps,
               :short_periods => short_periods,
               :long_periods => long_periods,
               :no_user => no_user,
               :no_task => no_task,
               :no_company => no_company
  end

  def nagging(sent_at = Time.now)
    subject    'DatabaseCheckMailer#nagging'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end
end
