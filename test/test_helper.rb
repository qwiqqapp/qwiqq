ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'

# stop all network requests,
# will throw exception if network request is issued
require 'fakeweb'
FakeWeb.allow_net_connect = false

# there's an issue with psych failing to parse dates on 1.9.2 
# so force the use of syck until the issue has been resolved
require 'yaml'
YAML::ENGINE.yamler= 'syck'

require 'factory_girl'
Factory.find_definitions

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation #when not using trasactional fixtures

require 'thinking_sphinx/test'
ThinkingSphinx::Test.init

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
end

# ------------
# helper methods
def json_response
  ActiveSupport::JSON.decode(@response.body)
end

def sign_in(user)
  @controller.stubs(:current_user).returns(user)
end

def sign_out
  @controller.stubs(:current_user).returns(nil)
end





