require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "authenticate user" do
    @password   = 'tester'
    @user       = Factory(:user, :password => @password, :password_confirmation => @password)
    @auth_user  = User.authenticate!(@user.email, @password)
    
    assert_equal @user, @auth_user
  end

  test "friendship is bidirectional" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    @user3 = Factory(:user)
    
    @user0.create_friendship(@user1).accept!
    @user2.create_friendship(@user1).accept!

    assert_equal 1, @user0.friends.size
    assert_equal 2, @user1.friends.size
    assert_equal 1, @user2.friends.size
    assert_equal 0, @user3.friends.size
  end
  
end