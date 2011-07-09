require 'test_helper'

class Api::FriendsControllerTest < ActionController::TestCase
  test "should route to friends#find" do
    assert_routing({ :method => "post", :path => "/api/users/1/find_friends.json" }, { 
      :format => "json", 
      :controller => "api/friends", 
      :action => "find",
      :user_id => "1" })
  end
  
  test "should find friends by email" do
    @user0 = Factory(:user)
    sign_in(@user0)

    @user1 = Factory(:user, :email => "user1@gastownlabs.com")
    @user2 = Factory(:user, :email => "user2@gastownlabs.com")
    Invitation.create(:user => @user0, :service => "email", :email => "user4@gastownlabs.com")
    @user0.follow!(@user1)

    post :find, 
      :format => "json",
      :user_id => @user0.id, 
      :service => "email", 
      :emails => [ 
        "user1@gastownlabs.com",  # found, following
        "user2@gastownlabs.com",  # found, not following
        "user3@gastownlabs.com",  # not found, not invited
        "user4@gastownlabs.com" ] # not found, invited

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 4, json_response.size

    assert_equal({ "email" => "user1@gastownlabs.com", "state" => "following", "user_id" => @user1.id }, json_response[0])
    assert_equal({ "email" => "user2@gastownlabs.com", "state" => "not_following", "user_id" => @user2.id }, json_response[1])
    assert_equal({ "email" => "user3@gastownlabs.com", "state" => "not_invited" }, json_response[2])
    assert_equal({ "email" => "user4@gastownlabs.com", "state" => "invited" }, json_response[3])
  end

  test "should by friends on twitter" do
    @user0 = Factory(:user)
    sign_in(@user0)

    @user1 = Factory(:user, :twitter_id => "1", :email => "user1@gastownlabs.com") # following
    @user2 = Factory(:user, :twitter_id => "2", :email => "user2@gastownlabs.com") # not_following
    @user3 = Factory(:user, :twitter_id => "3", :email => "user3@gastownlabs.com") 

    @user0.follow!(@user1)

    twitter_client = mock({ :friends => [ { "id" => "1" }, { "id" => "2" } ] })
    User.any_instance.stubs(:twitter_client).returns(twitter_client)

    post :find,
      :format => "json",
      :user_id => @user0.id,
      :service => "twitter"

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 2, json_response.size

    assert_equal({ "email" => "user1@gastownlabs.com", "state" => "following", "user_id" => @user1.id }, json_response[0])
    assert_equal({ "email" => "user2@gastownlabs.com", "state" => "not_following", "user_id" => @user2.id }, json_response[1])
  end
end

