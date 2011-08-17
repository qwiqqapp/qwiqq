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
set :use_sudo, false
set :unicorn_pid_path, "#{shared_path}/pids/unicorn.pid"
set :unicorn, "unicorn"

role :app, "ec2-50-18-179-179.us-west-1.compute.amazonaws.com", "ec2-50-18-179-224.us-west-1.compute.amazonaws.com" 

namespace :deploy do
  task :start, :roles => :app do
    run "cd #{current_path} && bundle exec #{unicorn} -c #{current_path}/config/unicorn.rb -D -E production"
  end

  task :stop, :roles => :app do
    run "if [ -e #{unicorn_pid_path} ]; then kill -s QUIT `cat #{unicorn_pid_path}`; fi"
  end
  
  task :reload, :roles => :app do
    run "if [ -e #{unicorn_pid_path} ]; then kill -s HUP `cat #{unicorn_pid_path}`; fi"
  end

  task :restart, :roles => :app do
    stop
    start
  end

  task :copy_config, :roles => :app do
    run "cp -pf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:symlink", "deploy:copy_config"
