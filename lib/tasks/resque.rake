require "resque/pool/tasks"

# this task will get called before resque:pool:setup
# and preload the rails environment in the pool manager
task "resque:setup" => :environment do
  # generic worker setup, e.g. Hoptoad for failed jobs
end

task "resque:pool:setup" do
  # close any sockets or files in pool manager
  ActiveRecord::Base.connection.disconnect!

  # and re-open them in the resque worker parent
  Resque::Pool.after_prefork do |job|
    ActiveRecord::Base.establish_connection
  end
end

task "resque:web:start" => :environment do
  require "resque/server"
  require "vegas"
  Resque::Server.use Rack::Auth::Basic do |username, password|
    # TODO put credentials in config
    [ username, password ] == [ "admin", "@1t@vist@" ] 
  end
  Vegas::Runner.new(Resque::Server, "resque-web")
end
