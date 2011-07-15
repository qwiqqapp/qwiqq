require 'test_helper'

class Api::RelationshipsControllerTest < ActionController::TestCase

  test "should route to relationships#create" do
    assert_routing({ :method => "post", :path => "/api/users/1/following.json" }, {
      :format => "json", :controller => "api/relationships", :action => "create", :user_id => "1" })
  end

  test "should create a relationship" do
    @user = Factory(:user)
    @target = Factory(:user)
    sign_in(@user)

    post :create, :user_id => @user.id , :target_id => @target.id, :format => "json"

    assert_equal 201, @response.status
    assert_equal [@target], @user.following
    assert_equal 1, json_response["followers_count"]
    assert_equal 0, json_response["following_count"]
    assert_equal 0, json_response["friends_count"]
  end

  test "should destroy a relationship" do
    @user = Factory(:user)
    @target = Factory(:user)
    sign_in(@user)

    @user.follow!(@target)

    post :destroy, :user_id => @user.id , :target_id => @target.id, :format => "json"

    assert_equal 200, @response.status
    assert_equal [], @user.following
    assert_equal 0, json_response["followers_count"]
    assert_equal 0, json_response["following_count"]
    assert_equal 0, json_response["friends_count"]
  end
  
  test "should now allow self follow" do
    @user = Factory(:user)
    sign_in(@user)

    post :create, :user_id => @user.id , :target_id => @user.id, :format => "json"

    assert_equal 405,       @response.status
    assert_match /unable to follow/i, json_response['message']
  end
end
