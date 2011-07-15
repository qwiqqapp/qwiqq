require 'test_helper'

class Api::PasswordResetsControllerTest < ActionController::TestCase
  
  test "should route to password_resets#create" do
    assert_routing(
        {:method => 'post', :path => "/api/password_resets.json"}, 
        {:format => "json", :controller => "api/password_resets", :action => "create" })
  end
  
  test "should route to password_resets#show" do
    assert_routing("/api/password_resets/Ckx5dawt9eOl5Le4gIhKyv18.json", {
      :format => "json", :controller => "api/password_resets", :action => "show", :id => "Ckx5dawt9eOl5Le4gIhKyv18" })
  end
  
  
  test "should set password reset attributes for valid user" do
    @user = Factory(:user, :reset_password_token => nil)
    Mailer.expects(:password_reset).with(@user, @user.email).returns(mock(:deliver => true)).once
    
    post :create, :email => @user.email, :format => 'json'
  
    assert_equal 201, @response.status
    assert_not_nil assigns(:user).reset_password_token
    assert_not_nil assigns(:user).reset_password_sent_at
  end
  
  test "should send password reset instructions for valid email" do
    @user = Factory(:user)
    post :create, :email => @user.email, :format => 'json'
    
    email = ActionMailer::Base.deliveries.last.to_s
    token = assigns(:user).reset_password_token
    
    assert_equal 201, @response.status
    assert_not_nil token
    assert_match Regexp.new(Regexp.escape("qwiqq:///password_reset/#{token}")), email
  end
  
  test "should NOT send password reset instructions for INVALID email" do
    Mailer.expects(:password_reset).never
    post :create, :email => 'test@testerson.com', :format => 'json'
    
    assert_equal 404, @response.status
    assert_match /unable to find/i, json_response['message']
  end
  
  test "should return user for valid password reset token" do
    token = 'Ckx5dawt9eOl5Le4gIhKyv18'
    @user = Factory(:user, :reset_password_token => token)
    
    get :show, :id => token, :format => 'json'
    
    assert_equal 200, @response.status
    assert_equal @user.email, json_response['email']
  end
  
  test "should NOT user for invalid password reset token" do
    token = 'Ckx5dawt9eOl5Le4gIhKyv18'
    @user = Factory(:user, :reset_password_token => token)
    
    get :show, :id => 'invalid', :format => 'json'
    
    assert_equal 404, @response.status
    assert_match /no longer valid/i, json_response['message']
  end
end
