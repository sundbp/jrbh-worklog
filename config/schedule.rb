# Use this file to easily define all of your cron jobs.

#set :output, "/home/patrik/www/jrbh-worklog/current/log/cron_log.log"

every 1.day, :at => '2.30pm' do
  command "/home/patrik/www/jrbh-worklog/current/script/worklog-backup.sh"
end
