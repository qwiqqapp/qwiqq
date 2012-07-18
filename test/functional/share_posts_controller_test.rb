require 'test_helper'

class Api::SharePostsControllerTest < ActionController::TestCase
  
  test "should route to share_posts#mail" do
    assert_routing(
        {:method => 'post', :path => "/api/share_posts.json"}, 
        {:format => "json", :controller => "api/share_posts", :action => "mail" })
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