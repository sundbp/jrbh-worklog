# Use this file to easily define all of your cron jobs.

#set :output, "/home/patrik/www/jrbh-worklog/current/log/cron_log.log"

every 1.day, :at => '2.30am' do
  runner "DatabaseBackup.daily_backup"
end

every 1.month, :at => '2.35am' do
  runner "DatabaseBackup.monthly_backup"
end

every 1.day, :at => '11.00am' do
  runner "DatabaseCheckMailer.run_nagging_check"
end

every 1.day, :at => '7.00am' do
  runner "DatabaseCheckMailer.run_consistency_check"
end

every :monday, :at => '7.00am' do
  runner "DatabaseCheckMailer.run_gap_check"
  runner "DatabaseCheckMailer.run_unusually_long_periods_check"
end

every 1.week, :at => '19pm' do
  runner "WorkPeriodsFlattener.flatten_work_periods"
end
