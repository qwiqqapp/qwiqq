require 'test_helper'

class Api::UsersControllerTest < ActionController::TestCase

  test "should route to users#create.json" do
    assert_routing({:method => 'post', :path => '/api/users.json'}, 
                   {:format => 'json', :controller => "api/users", :action => "create"})
  end
  
  test "should route to users#show" do
    assert_routing('/api/users/1.json', 
                   {:format => 'json', :controller => "api/users", :action => "show", :id => "1"})
  end
  
  test "should route with special case current user id to users#show" do
    assert_routing('/api/users/current.json', 
                   {:format => 'json', :controller => "api/users", :action => "show", :id => "current"})
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
  
  # users#show with current
  test 'should render current_users details' do
    @user = Factory(:user)
    @deals = [Factory(:deal, :user => @user), Factory(:deal, :user => @user)]
    sign_in(@user)
    
    get :show, :id => "current", :format => 'json'
    assert_equal 200, @response.status
    assert_equal 2, json_response['deals'].size
  end
  
end
