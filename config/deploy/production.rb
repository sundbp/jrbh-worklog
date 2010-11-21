set :deploy_to,   "/home/#{user}/www/production/#{application}"
set :rails_env,   :production
set :branch,      "production"

# only run whenever in prod
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"
