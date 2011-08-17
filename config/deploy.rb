require "./config/boot"
require "bundler/capistrano"
require "hoptoad_notifier/capistrano"

set :application, "qwiqq"
set :repository,  "git@github.com:gastownlabs/qwiqq-web.git"
set :deploy_to, "/var/www/qwiqq.me"
set :user, "ubuntu"
set :ssh_options, { :keys => [ File.join(ENV["EC2_KEY"]) ] }
set :scm, :git
set :branch, "production"
set :deploy_via, :remote_cache

role :app, "ec2-204-236-148-102.us-west-1.compute.amazonaws.com" #, "app1.qwiqq.me"

set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"
set :unicorn_rails, "unicorn_rails"

namespace :deploy do
  task :start, :roles => :app do
    run "#{unicorn_rails} -c #{deploy_to}/current/config/unicorn.rb -D -E production"
  end

  task :stop, :roles => :app do
    run "kill `cat #{unicorn_pid}`" if File.exists?(unicorn_pid)
  end
  
  task :reload, :roles => :app do
    run "kill -s USR2 `cat #{unicorn_pid}`" if File.exists?(unicorn_pid)
  end

  task :restart, :roles => :app do
    stop
    start
  end
end

