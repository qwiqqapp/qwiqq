require "./config/boot"
require "bundler/capistrano"
require "hoptoad_notifier/capistrano"

# an EC2 key is required
raise "Environment variable 'EC2_KEY' is required." unless ENV["EC2_KEY"]

set :application, "qwiqq"
set :repository,  "git@github.com:gastownlabs/qwiqq-web.git"
set :deploy_to, "/var/www/qwiqq.me"
set :user, "ubuntu"
set :ssh_options, { :keys => [ File.join(ENV["EC2_KEY"]) ] }
set :scm, :git
set :branch, "production"
set :deploy_via, :remote_cache

role :app, "ec2-204-236-148-102.us-west-1.compute.amazonaws.com" #, "app1.qwiqq.me"

set :unicorn_pid_path, "#{shared_path}/pids/unicorn.pid"
set :unicorn_rails, "unicorn_rails"

namespace :deploy do
  task :start, :roles => :app do
    run "cd #{current_path} && bundle exec #{unicorn_rails} -c #{current_path}/config/unicorn.rb -D -E production"
  end

  task :stop, :roles => :app do
    run "kill `cat #{unicorn_pid_path}`" if File.exists?(unicorn_pid_path)
  end
  
  task :reload, :roles => :app do
    run "kill -s USR2 `cat #{unicorn_pid_path}`" if File.exists?(unicorn_pid_path)
  end

  task :restart, :roles => :app do
    stop
    start
  end
end

