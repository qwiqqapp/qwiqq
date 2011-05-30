require 'test_helper'

class Api::SessionsControllerTest < ActionController::TestCase

  test "should route to sessions#create" do
    assert_routing({:method => 'post', :path => '/api/sessions.json'}, 
                   {:format => 'json', :controller => "api/sessions", :action => "create"})
  end
  
  test "should route to sessions#destroy" do
    assert_routing({:method => 'delete', :path => '/api/sessions/1.json'}, 
                   {:format => 'json', :controller => "api/sessions", :action => "destroy", :id => '1'})
  end
  
  test "should sign in valid user" do
    @user = Factory(:user)
    post :create, :user => { :email => @user.email, :password => @user.password}, :format => 'json'
    assert_equal 200, @response.status
    assert_equal @user.email, json_response['email']
  end

  test "should not authorize user with invalid password" do
    @user = Factory(:user)
    post :create, :user => { :email => @user.email, :password => 'invalid'}, :format => 'json'
    assert_equal 401, @response.status
  end
  
  test "should not find invalid user" do
    post :create, :user => { :email => 'invalid', :password => 'invalid'}, :format => 'json'
    assert_equal 404, @response.status
  end
end
