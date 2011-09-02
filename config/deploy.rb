require "./config/boot"
require "bundler/capistrano"
require "hoptoad_notifier/capistrano"
require "new_relic/recipes"
require "capistrano/ext/multistage"

# an EC2 key is required
raise "Environment variable 'EC2_KEY' is required." unless ENV["EC2_KEY"]

set :application, "qwiqq"
set :repository,  "git@github.com:gastownlabs/qwiqq-web.git"
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
    run "cd #{current_path} && bundle exec unicorn -c #{current_path}/config/unicorn.rb -D -E production"
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
    run "cd #{current_path} && bundle exec resque-pool --daemon --environment production"
  end

  def stop_resque
    # QUIT tells resque-pool to wait for workers to finish and quit
    run "if [ -e #{resque_pid_path} ]; then kill -s QUIT `cat #{resque_pid_path}`; fi"
  end

  task :start, :roles => :worker do
    start_resque
  end

  task :restart, :roles => :worker do
    # this is ugly, but resque-pool doesnt support master restarts
    stop_resque
    sleep(30)
    start_resque
  end

  task :stop, :roles => :worker do
    stop_resque
  end
end

# sphinx tasks
namespace :sphinx do
  task :configure, :roles => [ :search ] do
    run "sed -i 's/address:.*/address:0.0.0.0/g' #{release_path}/config/sphinx.yml"
    run_task "thinking_sphinx:configure"
  end
  
  task :start, :roles => [ :search ] do
    run_task "thinking_sphinx:start"
  end
  
  task :restart, :roles => [ :search ] do
    run_task "thinking_sphinx:restart"
  end
end

# papertrails tasks 
namespace :papertrail do
  task :restart, :roles => [ :app, :worker, :search ] do
    run "sudo /etc/init.d/papertrail restart"
  end
end

# general tasks
namespace :deploy do
  task :copy_config, :roles => [ :app, :worker, :search ] do
    run "cp -pf #{release_path}/config/deploy/config/* #{release_path}/config/"
  end
end

# utilities
def run_task(name)
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake #{name}"
end

def prompt(message, default)
  response = Capistrano::CLI.ui.ask "#{message} [#{default}]: "
  response.empty? ? default : response
end

after "deploy:update_code", "deploy:copy_config", "sphinx:configure"
after "deploy:update", "newrelic:notice_deployment"
after "deploy:restart", "unicorn:reload", "resque:restart", "papertrail:restart", "sphinx:restart"
after "deploy:start", "unicorn:start", "resque:start", "sphinx:start"

