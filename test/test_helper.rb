ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require 'factory_girl'

# there's an issue with psych failing to parse dates on 1.9.2 
# so force the use of syck until the issue has been resolved
YAML::ENGINE.yamler= 'syck'

class ActiveSupport::TestCase
  def json_response
    ActiveSupport::JSON.decode(@response.body)
  end
end

def sign_in(user)
  @controller.stubs(:current_user).returns(user)
end

def sign_out
  @controller.stubs(:current_user).returns(nil)
end

Factory.find_definitions
