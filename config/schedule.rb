# Use this file to easily define all of your cron jobs.

set :output, "/home/patrik/www/jrbh-worklog/current/log/cron_log.log"

every 1.day, :at => '1pm' do
  command "mv /home/patrik/Dropbox/jrbh_prod.dump /home/patrik/Dropbox/jrbh_prod.dump.1"
  command "mv /home/patrik/Dropbox/jrbh_prod.dump.1 /home/patrik/Dropbox/jrbh_prod.dump.2"
  command "mv /home/patrik/Dropbox/jrbh_prod.dump.2 /home/patrik/Dropbox/jrbh_prod.dump.3"
  command "mv /home/patrik/Dropbox/jrbh_prod.dump.3 /home/patrik/Dropbox/jrbh_prod.dump.4"
  command "mv /home/patrik/Dropbox/jrbh_prod.dump.4 /home/patrik/Dropbox/jrbh_prod.dump.5"
  command "/usr/bin/pg_dump jrbh_prod > /home/patrik/Dropbox/jrbh_prod.dump"
end
