set :application, "qwiqq"
set :repository,  "git@github.com:gastownlabs/qwiqq-web.git"
set :deploy_to, "/var/www/qwiqq.me"

set :scm, :git
set :branch, "production"
set :deploy_via, :remote_cache

role :app, "ec2-204-236-148-102.us-west-1.compute.amazonaws.com" #, "app1.qwiqq.me"

set :user, "ubuntu"
set :ssh_options, { :keys => [ File.join(ENV["EC2_KEY"]) ] }

require "./config/boot"
require "bundler/capistrano"
require "hoptoad_notifier/capistrano"

task :ssh do
  ssh "ssh git@github.com"
end
