require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "#authenticate" do
    @password   = 'tester'
    @user       = Factory(:user, :password => @password, :password_confirmation => @password)
    @auth_user  = User.authenticate(@user.email, @password)
    
    assert_equal @user, @auth_user
  end

  test "#following" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    
    @user0.follow!(@user1)

    assert_equal 1, @user0.following.count
    assert_equal 0, @user0.followers.count
    assert_equal 0, @user1.following.count
    assert_equal 1, @user1.followers.count
  end

  test "#friends" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    
    @user0.follow!(@user1)
    @user1.follow!(@user0)
    @user0.follow!(@user2)

    assert_equal [@user1], @user0.friends
    assert_equal [@user0], @user1.friends
    assert_equal 1, @user0.friends.count
    assert_equal 1, @user1.friends.count
  end

  test "#friends?" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    
    @user0.follow!(@user1)
    @user1.follow!(@user0)
    @user0.follow!(@user2)

    assert @user1.friends?(@user0)
    assert @user0.friends?(@user1)
    
    assert !@user0.friends?(@user2)
    assert !@user2.friends?(@user0)
  end

  test "#following?" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    
    @user0.follow!(@user1)

    assert @user0.following?(@user1)
  end

  test "#feed_deals" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    @user3 = Factory(:user)

    @user0.follow!(@user1)
    @user0.follow!(@user2)

    @deal0 = Factory(:deal, :user => @user1, :created_at => 1.hour.ago)
    @deal1 = Factory(:deal, :user => @user2, :created_at => 2.hours.ago)
    @deal2 = Factory(:deal, :user => @user0, :created_at => 3.hours.ago)
    @deal3 = Factory(:deal, :user => @user3, :created_at => 4.hours.ago)

    @user0.repost_deal!(@deal3)

    assert_equal 2, @user0.feed_deals.count
    assert_equal [@deal0, @deal1], @user0.feed_deals 
  end
  
  test "#feed_deals with reposts from followed users" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    @user3 = Factory(:user)

    @user0.follow!(@user1)
    @user0.follow!(@user2)

    @deal0 = Factory(:deal, :user => @user1, :created_at => 1.hour.ago)
    @deal1 = Factory(:deal, :user => @user2, :created_at => 2.hours.ago)
    @deal2 = Factory(:deal, :user => @user0, :created_at => 3.hours.ago)
    @deal3 = Factory(:deal, :user => @user3, :created_at => 4.hours.ago)

    @user1.repost_deal!(@deal3)

    assert_equal 3, @user0.feed_deals.count
    assert_equal [@deal0, @deal1, @deal3], @user0.feed_deals 
  end

  test "should update twitter_id when twitter_access_token changes" do
    @user = Factory(:user)

    twitter_user = mock(:id => 1)
    twitter_client = mock(:user => twitter_user)
    @user.stubs(:twitter_client).returns(twitter_client)
    @user.update_attributes(
      :twitter_access_token => "token",
      :twitter_access_secret => "secret")

    assert_equal "1", @user.twitter_id 
  end
  
  test "should update facebook_id when facebook_access_token changes" do
    @user = Factory(:user)

    facebook_client = mock()
    facebook_client.expects(:get_object).with("me").returns({ "id" => "1"})
    @user.stubs(:facebook_client).returns(facebook_client)
    @user.update_attributes(:facebook_access_token => "token")

    assert_equal "1", @user.facebook_id 
  end

  test "should strip text attributes before saving" do
    @user = Factory(:user,
      :email => "    eoin@gastownlabs.com     ",
      :city => "     Vancouver    ",
      :country => "     Canada    ",
      :first_name => " Eoin    ",
      :last_name => "    Hennessy   ",
      :username => "     eoin    ",
      :bio => "          ")

    assert_equal "eoin@gastownlabs.com", @user.email
    assert_equal "Vancouver", @user.city
    assert_equal "Canada", @user.country
    assert_equal "Eoin", @user.first_name
    assert_equal "Hennessy", @user.last_name
    assert_equal "eoin", @user.username
    assert_equal "", @user.bio
  end
end