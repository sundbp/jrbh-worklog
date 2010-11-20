# Warning to my picky self: order of requires matters because they define new tasks and
# affect order of task operation.

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, "1.9.2@worklog"
set :rvm_type, :user
set :use_sudo, false

set :stages, %w(testing staging production)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

default_run_options[:pty]   = true # must be set for the password prompt from git to work
ssh_options[:forward_agent] = true # use local keys instead of the ones on the server

set :application, "jrbh-worklog"
set :repository,  "git@github.com:sundbp/#{application}.git"

set :scm, :git
set :user, "patrik"
set :branch, "rails3"
set :deploy_via, :remote_cache

role :web, "bob.jrbh.local"
role :app, "bob.jrbh.local"
role :db,  "bob.jrbh.local", :primary => true

after "deploy:update_code", "deploy:update_shared_symlinks"
require "bundler/capistrano"
after "bundle:install", "deploy:migrate"

after "deploy:symlink", "deploy:update_yml_files"

namespace :deploy do
  task :start do ; end
  task :stop  do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path, "tmp/restart.txt")}"
  end

  task :update_shared_symlinks do
    %w(config/database.yml).each do |path|
      run "rm -rf #{File.join(release_path, path)}"
      run "ln -s #{File.join(deploy_to, "shared", path)} #{File.join(release_path, path)}"
    end
  end
  
  desc "Update the configuration .yml files"
  task :update_yml_files, :roles => :db do
    top.upload "config/database.yml", File.join(release_path, "config", "database.yml") 
    top.upload "config/app_config.yml", File.join(release_path, "config", "app_config.yml") 
  end
end

# 
# set :user,        "patrik"
# set :domain,      "bob.jrbh.local"
# set :application, "jrbh-worklog"
# 
# set :repository,  "git@github.com:sundbp/#{application}.git"
# set :deploy_to,   "/home/#{user}/www/#{application}"
# set :use_sudo,    false
# 
# set :scm, :git
# # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
# 
# role :web, domain                         # Your HTTP server, Apache/etc
# role :app, domain                          # This may be the same as your `Web` server
# role :db,  domain, :primary => true # This is where Rails migrations will run
# 
# default_run_options[:pty] = true
# set :ssh_options, {:forward_agent => true}
# 
# namespace :deploy do
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
# 
# after "deploy:symlink", "deploy:update_crontab"
# namespace :deploy do
#   desc "Update the crontab file"
#   task :update_crontab, :roles => :db do
#     run "cd #{release_path} && whenever --update-crontab #{application}"
#   end
# end
# 
# 
# after "deploy:symlink", "deploy:update_yml_files"
# namespace :deploy do
#   desc "Update the configuration .yml files"
#   task :update_yml_files, :roles => :db do
#     top.upload "config/database.yml", File.join(release_path, "config", "database.yml") 
#     top.upload "config/app_config.yml", File.join(release_path, "config", "app_config.yml") 
#   end
# end
