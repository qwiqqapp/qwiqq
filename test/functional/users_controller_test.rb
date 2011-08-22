require 'test_helper'

class Api::UsersControllerTest < ActionController::TestCase

  setup do
    stub_indextank
  end

  test "should route to users#create" do
    assert_routing({:method => "post", :path => "/api/users.json"}, 
                   {:format => "json", :controller => "api/users", :action => "create"})
  end
  
  test "should route to users#update" do
    assert_routing({:method => "put", :path => "/api/users/current.json"}, 
                   {:format => "json", :controller => "api/users", :action => "update", :id => "current"})
  end

  test "should route to users#show" do
    assert_routing("/api/users/1.json", 
                   {:format => "json", :controller => "api/users", :action => "show", :id => "1"})
  end
  
  test "should route to users#followers" do
    assert_routing("/api/users/1/followers.json", 
                   {:format => "json", :controller => "api/users", :action => "followers", :id => "1"})
  end
  
  test "should route to users#following" do
    assert_routing("/api/users/1/following.json", 
                   {:format => "json", :controller => "api/users", :action => "following", :id => "1"})
  end
  
  test "should route to users#friends" do
    assert_routing("/api/users/1/friends.json", 
                   {:format => "json", :controller => "api/users", :action => "friends", :id => "1"})
  end
  
  test "user registration" do
    @user_params = Factory.attributes_for(:user)
    post :create, :user => @user_params, :format => 'json'
    
    assert_equal 201, @response.status
    assert_equal @user_params[:email], json_response['email']
  end

  test "failed user registration" do
    @user_params = Factory.attributes_for(:user)
    @user_params.delete(:email)
    post :create, :user => @user_params, :format => 'json'
    
    assert_equal 422, @response.status
    assert_equal ["can't be blank"], json_response['email']
  end
  
  # users#show
  test "should render users details" do
    @user = Factory(:user)
    sign_in(@user)
    
    get :show, :id => @user.id, :format => 'json'
    assert_equal 200, @response.status
  end

  # users#show for current user
  test "should render current_users details" do
    @user = Factory(:user)
    @deals = [Factory(:deal, :user => @user), Factory(:deal, :user => @user)]
    sign_in(@user)


    get :show, :id => "current", :format => 'json'

    assert_equal 200, @response.status
    assert_equal 2, json_response['deals'].size
  end

  # users#followers
  test "should render a users followers" do
    @user0 = Factory(:user)
    sign_in(@user0)

    @user1 = Factory(:user)
    @user2 = Factory(:user)
    @user1.follow!(@user0)
    @user2.follow!(@user0)
    
    get :followers, :id => @user0.id, :format => 'json'

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 2, json_response.size
  end

  # users#following
  test "should render the users a user follows" do
    @user0 = Factory(:user)
    sign_in(@user0)

    @user1 = Factory(:user)
    @user2 = Factory(:user)
    @user0.follow!(@user1)
    @user0.follow!(@user2)
    
    get :following, :id => @user0.id, :format => 'json'

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 2, json_response.size
  end

  # users#friends
  test "should render a users friends" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)

    sign_in(@user0)

    @user0.follow!(@user1)
    @user1.follow!(@user0)
    
    get :following, :id => @user0.id, :format => 'json'
    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 1, json_response.size
  end
  
  # users#update
  test "should allow the current user to be updated" do
    @user = Factory(:user)
    sign_in(@user)

    @user_params = {
      :first_name => "Bilbo",
      :last_name => "Baggins",
      :username => "bilbo",
      :email => "bilbo@theshire.com", 
      :country => "Middle Earth", 
      :city => "The Shire", 
      :facebook_access_token => "token"
    }
 
    put :update, :id => "current", :user => @user_params, :format => "json"

    assert_equal 200, @response.status
    assert_equal "token", @user.facebook_access_token

    # the response should contain the updated user
    assert_equal "Bilbo", json_response["first_name"]
    assert_equal "Baggins", json_response["last_name"]
  end

  # users#update
  test "should return validation errors when updating the user failed" do
    @user = Factory(:user)
    sign_in(@user)

    @user_params = { :email => "" }
    put :update, :id => "current", :user => @user_params, :format => "json"
    
    assert_equal 422, @response.status
    assert_match /blank/i, json_response["email"].first
  end
  
end
