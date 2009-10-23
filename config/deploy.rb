set :user,        "patrik"
set :domain,      "bob.jrbh.local"
set :application, "jrbh-worklog"

set :repository,  "git@github.com:sundbp/#{application}.git"
set :deploy_to,   "/home/#{user}/www/#{application}"
set :use_sudo,    false

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, domain                         # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

default_run_options[:pty] = true
set :ssh_options, {:forward_agent => true}

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:symlink", "deploy:update_crontab"
namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end