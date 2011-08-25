require "./config/boot"
require "bundler/capistrano"
require "hoptoad_notifier/capistrano"
require "capistrano/ext/multistage"

# an EC2 key is required
raise "Environment variable 'EC2_KEY' is required." unless ENV["EC2_KEY"]

set :application, "qwiqq"
set :repository,  "git@github.com:gastownlabs/qwiqq-web.git"
set :branch, "aws-production"
set :deploy_to, "/var/www/qwiqq.me"
set :user, "ubuntu"
set :ssh_options, { :keys => [ File.join(ENV["EC2_KEY"]) ] }
set :scm, :git
set :deploy_via, :remote_cache
set :use_sudo, false

set :unicorn_pid_path, "#{shared_path}/pids/unicorn.pid"
set :resque_pid_path, "#{shared_path}/pids/resque-pool.pid"

# unicorn tasks
namespace :unicorn do
  task :start, :roles => :app do
    run "cd #{current_path} && bundle exec unicorn -c #{current_path}/config/unicorn.rb -D -E #{stage}"
  end

  task :graceful_stop, :roles => :app do
    # QUIT tells unicorn to wait for workers to complete and then dies
    run "if [ -e #{unicorn_pid_path} ]; then kill -s QUIT `cat #{unicorn_pid_path}`; fi"
  end
  
  task :reload, :roles => :app do
    # USR2 tells unicorn to start a new master, renaming the original PID
    run "if [ -e #{unicorn_pid_path} ]; then kill -s USR2 `cat #{unicorn_pid_path}`; fi"
  end
end

# resque tasks 
namespace :resque do
  def start_resque
    run "cd #{current_path} && bundle exec resque-pool --daemon --environment #{stage}"
  end

  def stop_resque
    # QUIT tells resque-pool to wait for workers to finish and quit
    run "if [ -e #{resque_pid_path} ]; then kill -s QUIT `cat #{resque_pid_path}`; fi"
  end

  task :start, :roles => :worker do
    start_resque
  end

  task :restart, :roles => :worker do
    stop_resque
    start_resque
  end

  task :stop, :roles => :worker do
    stop_resque
  end
end

# papertrails tasks 
namespace :papertrail do
  task :restart, :roles => [ :app, :worker ] do
    run "sudo /etc/init.d/papertrail restart"
  end
end

# general tasks
namespace :deploy do
  task :copy_config, :roles => [ :app, :worker ] do
    run "cp -pf #{shared_path}/config/* #{release_path}/config/"
  end
end

after "deploy:update_code", "deploy:copy_config"
after "deploy:restart", "unicorn:reload", "resque:restart", "papertrail:restart"
after "deploy:start", "unicorn:start", "resque:start"

