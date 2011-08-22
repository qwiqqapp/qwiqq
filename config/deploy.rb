require "./config/boot"
require "bundler/capistrano"

# an EC2 key is required
raise "Environment variable 'EC2_KEY' is required." unless ENV["EC2_KEY"]

set :application, "qwiqq"
set :repository,  "git@github.com:gastownlabs/qwiqq-web.git"
set :branch, "production"
set :deploy_to, "/var/www/qwiqq.me"
set :user, "ubuntu"
set :ssh_options, { :keys => [ File.join(ENV["EC2_KEY"]) ] }
set :scm, :git
set :deploy_via, :remote_cache
set :use_sudo, false
set :unicorn_pid_path, "#{shared_path}/pids/unicorn.pid"

role :app, "app1.qwiqq.me", "app2.qwiqq.me"
role :worker, "worker1.qwiqq.me"
role :db, "app1.qwiqq.me"

# helpers
def rake_task(name)
  cmd, args = "", ENV["RAKE_ARGS"].to_s.split(",")
  cmd << "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env, "production")} rake #{name}"
  cmd << "['#{args.join("','")}']" unless args.empty?
  cmd
end

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

# general tasks
namespace :deploy do
  task :copy_config, :roles => [ :app, :worker ] do
    run "cp -pf #{shared_path}/config/* #{current_path}/config/"
  end

  task :restart_papertrail, :roles => [ :app, :worker ] do
    run "sudo /etc/init.d/papertrail restart"
  end

  task :restart_workers, :roles => :worker do
    run rake_task "resque:restart_workers"
  end
end

after "deploy:symlink", "deploy:copy_config"
after "deploy:symlink", "deploy:restart_workers"
after "deploy:restart", "unicorn:reload", "deploy:restart_papertrail"
after "deploy:start", "unicorn:start"

