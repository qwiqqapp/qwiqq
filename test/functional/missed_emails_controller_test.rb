require 'test_helper'

class Api::MissedEmailsControllerTest < ActionController::TestCase
  
  test "should route to missed_emails#mail" do
    assert_routing(
        {:method => 'post', :path => "/api/missed_emails.json"}, 
        {:format => "json", :controller => "api/missed_emails", :action => "mail" })
  end
  
  
  # ----------------------
  # create
  
  test "should send password reset instructions for valid email" do
    @user = Factory(:user)
    post :mail, :email => @user.email, :format => 'json'
    
    email = ActionMailer::Base.deliveries.last.to_s
    
    assert_equal 201, @response.status
  end
  
  test "should NOT send welcome email for INVALID email" do
    Mailer.expects(:welcome_mail).never
    post :mail, :email => 'test@testerson.com', :format => 'json'
    
    assert_equal 404, @response.status
    assert_match /unable to find/i, json_response['message']
  end
  
end