require "resque"
require "resque/failure/multiple"
require "resque/failure/redis"
require "resque/failure/airbrake"

Resque::Failure::Multiple.classes = [ Resque::Failure::Redis, Resque::Failure::Airbrake ]
Resque::Failure.backend = Resque::Failure::Multiple
Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
Resque.after_fork do |worker|
  ActiveRecord::Base.establish_connection
end
