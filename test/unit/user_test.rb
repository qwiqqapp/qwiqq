require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "authenticate user" do
    @password   = 'tester'
    @user       = Factory(:user, :password => @password, :password_confirmation => @password)
    @auth_user  = User.authenticate!(@user.email, @password)
    
    assert_equal @user, @auth_user
  end

  test "a user can follow another user" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    
    @user0.follow!(@user1)

    assert_equal 1, @user0.following.size
    assert_equal 0, @user0.followers.size
    assert_equal 0, @user1.following.size
    assert_equal 1, @user1.followers.size
  end

  test "a user can have friends" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    
    @user0.follow!(@user1)
    @user1.follow!(@user0)
    @user0.follow!(@user2)

    assert_equal 3, Relationship.count
    assert_equal [@user1], @user0.friends
    assert_equal [@user0], @user1.friends
  end
  
end