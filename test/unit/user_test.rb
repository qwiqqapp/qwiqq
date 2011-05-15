require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "authenticate user" do
    @password   = 'tester'
    @user       = Factory(:user, :password => @password, :password_confirmation => @password)
    @auth_user  = User.authenticate!(@user.email, @password)
    
    assert_equal @user, @auth_user
  end
  
end