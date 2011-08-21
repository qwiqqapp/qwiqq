ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require 'factory_girl'
require 'fakeweb'

# there's an issue with psych failing to parse dates on 1.9.2 
# so force the use of syck until the issue has been resolved
require 'yaml'
YAML::ENGINE.yamler= 'syck'

# stop all network requests,
# will throw exception if network request is issued
FakeWeb.allow_net_connect = false

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

# TODO implement fakeweb register with valid responses,
# mocha stubs below are quick fix
def stub_indextank
  doc ||= Qwiqq::Indextank::Document.any_instance
  doc.stubs(:add).returns(true)
  doc.stubs(:remove).returns(true)
  doc.stubs(:sync_variables).returns(true)
  doc.stubs(:sync_variables).returns(true)
end

Factory.find_definitions
