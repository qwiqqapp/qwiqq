require 'test_helper'

class Api::UsersControllerTest < ActionController::TestCase

  test "should route to users#create" do
    assert_routing({:method => 'post', :path => '/api/users'}, 
                   {:controller => "api/users", :action => "create"})
  end
  
  test "user registration" do
    @user_params = Factory.attributes_for(:user)
    post :create, :user => @user_params, :format => 'json'
    
    assert_equal 200, @response.status
    assert_equal @user_params[:email], json_response['email']
  end
end
