# Use this file to easily define all of your cron jobs.

set :output, "/home/patrik/www/jrbh-worklog/current/log/cron_log.log"

every 1.day, :at => '12am' do
  command "rm -f /home/patrik/Dropbox/jrbh_prod.dump"
  command "/usr/bin/pg_dump jrbh_prod > /home/patrik/Dropbox/jrbh_prod.dump"
end
