# This file is used by Rack-based servers to start the application.

require ::File.expand_path("../config/environment",  __FILE__)
require "resque/server"

map "/admin/resque" do
  use Rack::Auth::Basic, do |username, password|
    [username, password] == [ 'gtl', 'mumfordmusic' ]
  end
  run Resque::Server.new
end

map "/" do
  run Qwiqq::Application
end
