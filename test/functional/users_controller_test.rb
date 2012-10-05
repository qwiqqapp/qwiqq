require 'test_helper'

class Api::UsersControllerTest < ActionController::TestCase
  
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

  test "should route to users#events" do
    assert_routing("/api/users/1/events.json", { :format => "json", :controller => "api/users", :action => "events", :id => "1" })
  end
  
  test "user registration" do
    @user_params = Factory.attributes_for(:user)
    post :create, :user => @user_params, :format => 'json'
    
    assert_equal 201, @response.status
    assert_equal @user_params[:email], json_response['email']
  end
  
  test "failed user registration with blank email" do
    @user_params = Factory.attributes_for(:user, :email => nil)
    post :create, :user => @user_params, :format => 'json'
    
    assert_equal 422, @response.status
    assert_equal ["can't be blank.", "is invalid"], json_response['email']
  end
  
  test "failed user registration with taken username" do
    @user = Factory(:user, :username => 'Adam')
    @user_params = Factory.attributes_for(:user, :username => 'adam')
    
    post :create, :user => @user_params, :format => 'json'
    
    assert_equal 422, @response.status
    assert_match /taken/i, json_response['username'].first
  end
  
  # users#show for a user other than the current user
  test "should render a users details" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    sign_in(@user0)
    
    get :show, :id => @user1.id, :format => 'json'
    assert_equal 200, @response.status
    assert_equal nil, json_response['events']
    assert_equal nil, json_response['email']
  end

  # users#show for the current user
  test "should render the current users details" do
    @user = Factory(:user)
    @deals = [Factory(:deal, :user => @user), Factory(:deal, :user => @user)]
    sign_in(@user)

    get :show, :id => "current", :format => 'json'

    assert_equal 200, @response.status
    assert_equal 2, json_response['deals'].size
    assert_equal 0, json_response['events'].size
    assert_equal @user.email, json_response['email']
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
  test "#update" do
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
    
    client = mock
    client.expects(:me).returns({'id' => '982739873298'})
    @user.expects(:facebook_client).returns(client)
    
    put :update, :id => "current", :user => @user_params, :format => "json"
    
    assert_equal 200, @response.status
    assert_equal "Bilbo", json_response["first_name"]
    assert_equal "Baggins", json_response["last_name"]
    
    # user should be updated
    assert_equal "token", @user.facebook_access_token
    assert_equal '982739873298', @user.facebook_id
  end
  
  
  test "#update should return 200 when users token is invalid for FB id update" do
    @user = Factory(:user)   
    sign_in @user
    
    @user_params = {
      :first_name => "Bilbo",
      :last_name => "Baggins",
      :username => "bilbo",
      :email => "bilbo@theshire.com", 
      :country => "Middle Earth",
      :city => "The Shire", 
      :facebook_access_token => "token"
    }
    
    client = mock
    client.expects(:me).raises(Facebook::InvalidAccessTokenError)
    @user.expects(:facebook_client).returns(client)
    
    put :update, :id => "current", :user => @user_params, :format => "json"
    assert_equal 200, @response.status
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

  # users#events
  test "should render a users events" do
    @user = Factory(:user)
    @deal = Factory(:deal, :user => @user)

    @like = Factory(:like, :deal => @deal)
    @share = Factory(:share, :deal => @deal, :service => "twitter")
    @comment = Factory(:comment, :deal => @deal)
    @relationship = Factory(:relationship, :target => @user)

    @like.create_event
    @comment.create_event
    @share.create_event
    @relationship.create_event

    sign_in @user
    get :events, :format => "json", :id => "current"

    assert_equal 200, @response.status
    assert_equal 4, json_response.size
  end

  # user#clear_events
  test "should clear a users unread events" do
    @user = Factory(:user)
    
    @deal = Factory(:deal, :user => @user)
    @like = Factory(:like, :deal => @deal)
    @like.create_event
    assert_equal 1, @user.events.unread.count
    
    sign_in @user
    post :clear_events, :format => "json", :id => "current"
    
    assert_equal 200, @response.status
    assert_equal 0, @user.events.unread.count
  end

  test "should return the current users facebook pages" do
    @user = Factory(:user)
    pages = [{ 'id' => "325173277528821", 'name' => "Gastown Labs", 'access_token' => "ADXVqk6fFwBACg3qmH9zJxVfrop7a9P2U" }]
    
    client = mock
    client.expects(:pages).returns(pages)
    @user.expects(:facebook_client).returns(client)
    
    sign_in @user
    get :facebook_pages, :format => "json", :id => "current"

    assert_equal 200, @response.status
    assert_equal 1, json_response.size
    assert_equal "Gastown Labs", json_response[0]["name"]
    assert_equal "325173277528821", json_response[0]["id"]
  end
  
  test "#facebook_pages should return 406 (not_acceptable) when users token is invalid" do
    @user = Factory(:user)    
    sign_in @user
    
    client = mock
    client.expects(:pages).raises(Facebook::InvalidAccessTokenError)
    @user.expects(:facebook_client).returns(client)
    
    get :facebook_pages, :format => "json", :id => "current"
    assert_equal 406, @response.status
  end
  
  
  test "#update should return 406 when users token is invalid for FB image update" do
    @user = Factory(:user)
    sign_in @user
    @user_params = {:photo_service => "facebook"}
    
    client = mock
    client.expects(:photo).raises(Facebook::InvalidAccessTokenError)
    @user.expects(:facebook_client).returns(client)
    
    put :update, :id => "current", :user => @user_params, :format => "json"
    assert_equal 406, @response.status
  end
  
end
