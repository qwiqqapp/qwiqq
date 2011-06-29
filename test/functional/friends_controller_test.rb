require 'test_helper'

class Api::FriendsControllerTest < ActionController::TestCase

  test "should route to friends#index for deals" do
    assert_routing("/api/users/1/friends.json", {
      :format => "json", :controller => "api/friends", :action => "index", :user_id => "1" })
  end

  test "should route to friends#pending for deals" do
    assert_routing("/api/users/1/friends/pending.json", {
      :format => "json", :controller => "api/friends", :action => "pending", :user_id => "1" })
  end

  test "should route to friends#create" do
    assert_routing({ :method => "post", :path => "/api/users/1/friends.json" }, {
      :format => "json", :controller => "api/friends", :action => "create", :user_id => "1" })
  end

  test "should route to friends#accept" do
    assert_routing({ :method => "post", :path => "/api/users/1/friends/2/accept.json" }, {
      :format => "json", :controller => "api/friends", :action => "accept", :user_id => "1", :id => "2" })
  end

  test "should route to friends#reject" do
    assert_routing({ :method => "post", :path => "/api/users/1/friends/2/reject.json" }, {
      :format => "json", :controller => "api/friends", :action => "reject", :user_id => "1", :id => "2" })
  end

  test "should return a users friends" do
    @user = Factory(:user)
    sign_in(@user)
    
    @friend0 = Factory(:user)
    @friend1 = Factory(:user)
    @user.friendships.create(:friend => @friend0, :status => Friendship::ACCEPTED)
    @user.friendships.create(:friend => @friend1)

    get :index, :user_id => @user.id, :format => :json

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 1, json_response.size
    assert_equal @friend0.id.to_s, json_response.first['user_id']
  end

  test "should return a users pending friend requests" do
    @user = Factory(:user)
    sign_in(@user)
    
    @friend0 = Factory(:user)
    @friend1 = Factory(:user)
    @user.friendships.create(:friend => @friend0, :status => Friendship::ACCEPTED)
    @user.friendships.create(:friend => @friend1)

    get :pending, :user_id => @user.id, :format => :json

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 1, json_response.size
    assert_equal @friend1.id.to_s, json_response.first['user_id']
  end

  test "should create a pending friendship for the current user" do
    @user = Factory(:user)
    @friend = Factory(:user)
    sign_in(@user)

    post :create, :user_id => @user.id, :format => :json, :friend_id => @friend.id

    assert_equal 201, @response.status
    assert_equal 0, @user.friends.count
    assert_equal 1, @user.pending_friends.count
  end

  test "should accept a pending friendship" do
    @user = Factory(:user)
    @friend = Factory(:user)
    @user.friendships.create(:friend => @friend)

    sign_in(@user)
    
    post :accept, :user_id => @user.id, :id => @friend.id, :format => :json

    assert_equal 200, @response.status
    assert_equal 1, @user.friends.count
    assert_equal 0, @user.pending_friends.count
  end
 
  test "should reject a pending friendship" do
    @user = Factory(:user)
    @friend = Factory(:user)
    @user.friendships.create(:friend => @friend)

    sign_in(@user)
    
    post :reject, :user_id => @user.id, :id => @friend.id, :format => :json

    assert_equal 200, @response.status
    assert_equal 0, @user.friends.count
    assert_equal 1, @user.rejected_friends.count
  end

end
