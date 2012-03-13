require 'test_helper'

class FacebookTest < ActiveSupport::TestCase
  
  setup do
    @user = Factory(:user)
    @facebook = Facebook.new(@user)    
  end
  
  test "#photos with a valid access token" do
    client = mock
    client.expects(:get_picture).with("me", :type => "large").returns("http://facebook.com/user.png")
    @facebook.expects(:client).returns(client)
    assert_equal @facebook.photo, "http://facebook.com/user.png"
  end
  
  # OAuthException: An active access token must be used to query information about the current user.
  test "#photos without an access token" do
    client = mock
    client.expects(:get_picture).raises(Koala::Facebook::APIError.new(
      {'type' => 'OAuthException',
       'message' => 'An active access token must be used to query information about the current user.'}))
      
    @facebook.expects(:client).returns(client)
    assert_raises Facebook::InvalidAccessTokenError do 
      @facebook.photo
    end
  end 
  
  # OAuthException: An active access token must be used to query information about the current user.
  test "#photos with an invalid access token" do
    @user.update_attribute(:facebook_access_token, "deadbeef")
    client = mock
    client.expects(:get_picture).raises(Koala::Facebook::APIError.new(
      {'type' => 'OAuthException', 'message' => 'Invalid OAuth access token.' }))
      
    @facebook.expects(:client).returns(client)
    assert_raises Facebook::InvalidAccessTokenError do 
      @facebook.photo
    end
    
    assert_equal nil, @user.facebook_access_token
  end  
  
  
  # get_connections("me", "friends")
  test "#friends" do
    results = mock([1,2,3])
    results.expects(:next_page).returns(nil).once
    
    client = mock
    client.expects(:get_connections).with("me", "friends").returns(results)
    @facebook.expects(:client).returns(client)
    
    assert_equal @facebook.friends, []
  end
  
  
  
end