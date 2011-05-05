ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/factories")
require 'rails/test_help'
require "authlogic/test_case"

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end

def sign_in(user)
  @controller.stubs(:current_user).returns(user)
end

def sign_out
  @controller.stubs(:current_user).returns(nil)
end
