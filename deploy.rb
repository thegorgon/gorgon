require './config/boot'
require 'bundler/capistrano'

set :application, "gorgon"
set :repository,  "git@github.com:thegorgon/gorgon.git"

set :scm, :git

set :scm,           "git"
set :scm_username,  'git'
set :user,          "medusa"
set :branch,        "master"
set :deploy_via,    :remote_cache
set :deploy_to,     '/u/app'
set :keep_releases, 10
set :rails_env,     'production'

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

role :web, "gorgon"
role :app, "gorgon"
role :db,  "gorgon", :primary => true


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :assets do
  task :optimize, :roles => :web do
    send(:run, "cd #{release_path} && RAILS_ENV=#{rails_env} rake assets:precompile:all")
  end
end

after 'deploy:update_code', 'assets:optimize'

after 'deploy' do
  system("git tag release-`date +%Y_%m_%d-%H%M`")
  system("git push origin master --tags")
end