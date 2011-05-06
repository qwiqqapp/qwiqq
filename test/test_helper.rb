ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_girl'

class ActiveSupport::TestCase

  def json_response
    ActiveSupport::JSON.decode(@response.body)
  end
end

Factory.find_definitions
