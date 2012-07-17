require 'test_helper'

class Api::PasswordResetsControllerTest < ActionController::TestCase
  
  test "should route to password_resets#create" do
    assert_routing(
        {:method => 'post', :path => "/api/password_resets.json"}, 
        {:format => "json", :controller => "api/password_resets", :action => "create" })
  end
  
  test "should route to password_resets#show" do
    assert_routing({:method => :put, :path => "/api/password_resets/Ckx5dawt9eOl5Le4gIhKyv18.json"}, {
      :format => "json", :controller => "api/password_resets", :action => "update", :id => "Ckx5dawt9eOl5Le4gIhKyv18" })
  end
  
  # ----------------------
  # create
  
  test "should set password reset attributes for valid user" do
    @user = Factory(:user, :reset_password_token => nil)
    Mailer.expects(:password_reset).with(@user).returns(mock(:deliver => true)).once
    
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
    assert_match Regexp.new(Regexp.escape("to=qwiqq%3A%2F%2F%2Fpassword_reset%2F#{token}")), email
  end
  
  test "should NOT send password reset instructions for INVALID email" do
    Mailer.expects(:password_reset).never
    post :create, :email => 'test@testerson.com', :format => 'json'
    
    assert_equal 404, @response.status
    assert_match /unable to find/i, json_response['message']
  end
  
  # ----------------------
  # update
  
  test "should accept update password for valid reset token" do
    token       = 'Ckx5dawt9eOl5Le4gIhKyv18'
    @user       = Factory(:user, :reset_password_token => token)
    
    put :update, :id => token, :password => 'acmecafe', :format => 'json'
    
    assert_equal 200,                              @response.status
    assert_equal @user.id,                         session[:user_id]
    assert_not_equal assigns(:user).password_hash, @user.password_hash
  end
  
  test "should NOT allow password update for invalid password reset token" do
    token = 'Ckx5dawt9eOl5Le4gIhKyv18'
    @user = Factory(:user, :reset_password_token => token)
    
    put :update, :id => 'invalid', :password => 'acmecafe', :format => 'json'
    
    assert_equal 404,                 @response.status
    assert_match /no longer valid/i,  json_response['message']
    assert_equal nil,                 session[:user_id] 
  end
  
  test "should NOT allow password update for invalid password (too short)" do
    token = 'Ckx5dawt9eOl5Le4gIhKyv18'
    @user = Factory(:user, :reset_password_token => token)
    
    put :update, :id => token, :password => 'abc', :format => 'json'
    
    assert_equal 422,      @response.status
    assert_equal nil,      session[:user_id]
    assert_match /short/i, json_response['password'].first
  end
end
