require 'test_helper'

class Api::FriendsControllerTest < ActionController::TestCase
  test "should route to friends#find" do
    assert_routing({ :method => "post", :path => "/api/users/1/find_friends.json" }, { 
      :format => "json", 
      :controller => "api/friends", 
      :action => "find",
      :user_id => "1" })
  end
  
  test "finds friends by email" do
    @user0 = Factory(:user, :email => "user0@gastownlabs.com")
    sign_in(@user0)

    @user1 = Factory(:user, :email => "user1@gastownlabs.com", :username => "1")
    @user2 = Factory(:user, :email => "user2@gastownlabs.com", :username => "2")
    Invitation.create(:user => @user0, :service => "email", :email => "user4@gastownlabs.com")
    @user0.follow!(@user1)

    post :find, 
      :format => "json",
      :user_id => @user0.id, 
      :service => "email", 
      :emails => [ 
        "user0@gastownlabs.com",  # found, self
        "user1@gastownlabs.com",  # found, following
        "user2@gastownlabs.com",  # found, not following
        "user3@gastownlabs.com",  # not found, not invited
        "user4@gastownlabs.com" ] # not found, invited

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 4, json_response.size

    assert_equal "user1@gastownlabs.com", json_response[0]["email"]
    assert_equal "following", json_response[0]["state"]
    assert_equal "user2@gastownlabs.com", json_response[1]["email"]
    assert_equal "not_following", json_response[1]["state"]
    assert_equal({ "email" => "user3@gastownlabs.com", "state" => "not_invited" }, json_response[2])
    assert_equal({ "email" => "user4@gastownlabs.com", "state" => "invited" }, json_response[3])
  end

  test "finds friends by email with no emails" do
    @user = Factory(:user)
    sign_in(@user)
    post :find,
      :format => "json",
      :user_id => @user.id,
      :service => "email"
    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 0, json_response.size
  end

  test "finds by friends on twitter" do
    @user0 = Factory(:user)
    sign_in(@user0)

    @user1 = Factory(:user, :twitter_id => "1", :email => "user1@gastownlabs.com", :first_name => "a", :last_name => "a", :username => "1") # following
    @user2 = Factory(:user, :twitter_id => "2", :email => "user2@gastownlabs.com", :first_name => "b", :last_name => "b", :username => "2") # not_following
    @user3 = Factory(:user, :twitter_id => "3", :email => "user3@gastownlabs.com", :first_name => "c", :last_name => "c", :username => "3") 
    @user0.follow!(@user1)

    User.any_instance.expects(:twitter_friend_ids).returns([ "1", "2", "4" ])

    post :find,
      :format => "json",
      :user_id => @user0.id,
      :service => "twitter"

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 2, json_response.size

    assert_equal "user1@gastownlabs.com", json_response[0]["email"]
    assert_equal "following", json_response[0]["state"]
    assert_equal "user2@gastownlabs.com", json_response[1]["email"]
    assert_equal "not_following", json_response[1]["state"]
  end

  test "finds by friends on facebook" do
    @user0 = Factory(:user)
    sign_in(@user0)

    @user1 = Factory(:user, :facebook_id => "1", :email => "user1@gastownlabs.com", :first_name => "a", :last_name => "a", :username => "1") # following
    @user2 = Factory(:user, :facebook_id => "2", :email => "user2@gastownlabs.com", :first_name => "b", :last_name => "b", :username => "2") # not_following
    @user3 = Factory(:user, :facebook_id => "3", :email => "user3@gastownlabs.com", :first_name => "c", :last_name => "c", :username => "3") 
    @user0.follow!(@user1)

    User.any_instance.stubs(:facebook_friend_ids).returns([ "1", "2", "4" ])

    post :find,
      :format => "json",
      :user_id => @user0.id,
      :service => "facebook"

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 2, json_response.size

    assert_equal "user1@gastownlabs.com", json_response[0]["email"]
    assert_equal "following", json_response[0]["state"]
    assert_equal "user2@gastownlabs.com", json_response[1]["email"]
    assert_equal "not_following", json_response[1]["state"]
  end

  test "fails when no service is provided" do
    @user0 = Factory(:user)
    sign_in(@user0)
    post :find, :format => "json", :user_id => @user0.id
    assert_equal 406, @response.status
  end
end

