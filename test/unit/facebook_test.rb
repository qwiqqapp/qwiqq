require 'test_helper'

class FacebookTest < ActiveSupport::TestCase
  
  setup do
    @user = Factory(:user)
    @facebook = Facebook.new(@user)    
  end
  
  test "#me" do
    facebook_response = {
      'id' => '123',
      'name' => 'adam'
    }
    client = mock
    client.expects(:get_object).with("me").returns(facebook_response)
    @facebook.expects(:client).returns(client)
    
    assert_equal @facebook.me.id, facebook_response['id']
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
  
  # Koala::Facebook::APIError: OAuthException: Error validating access token: The session has been invalidated because the user has changed the password.
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
  
  test "#friends" do
    results = [1,2,3]
    results.expects(:next_page).returns(nil).once
    
    client = mock
    client.expects(:get_connections).with("me", "friends").returns(results)
    @facebook.expects(:client).returns(client)
    
    assert_equal @facebook.friends, [1,2,3]
  end
  
  test "#friends without access token" do
    client = mock
    client.expects(:get_connections).raises(Koala::Facebook::APIError.new(
      {'type' => 'OAuthException',
       'message' => 'An active access token must be used to query information about the current user.'}))

    @facebook.expects(:client).returns(client)
    assert_raises Facebook::InvalidAccessTokenError do 
      @facebook.friends
    end
  end
  
  test "#pages" do
    facebook_response = [{ 
      "name" => "Gastown Labs", 
      "access_token" => "ADXVqk6fFwBACg3qmH9zJxVfrop7a9P2U",
      "category" => "Internet/software", 
      "id" => "325173277528821" 
    }]
    
    client = mock
    client.expects(:get_connections).with("me", "accounts").returns(facebook_response)
    @facebook.expects(:client).returns(client)
    
    @facebook.pages
  end
  
  test "#share" do
    share = Factory(:facebook_share, :user => @user, :facebook_page_id => '')
    client = mock
    client.expects(:put_connections).with("me", "links", anything)
    @facebook.expects(:client).returns(client)
    
    @facebook.share_link(share)
  end
  
  test "#share to page" do
    share = Factory(:facebook_share, :user => @user, :facebook_page_id => "3234592348234")
    client = mock
    client.expects(:put_connections).with("3234592348234", "links", anything)
    @facebook.expects(:client).returns(client)
    
    @facebook.share_link(share)
  end
  
  # Koala::Facebook::APIError: KoalaMissingAccessToken: Write operations require an access token
  test "#share with invalid access token" do
    share = Factory(:facebook_share, :user => @user)
    client = mock
    client.expects(:put_connections).raises(Koala::Facebook::APIError.new(
      {'type' => 'KoalaMissingAccessToken',
       'message' => 'Write operations require an access token'}))

    @facebook.expects(:client).returns(client)
    
    assert_raises Koala::Facebook::APIError do 
      @facebook.share_link(share)
    end
  end
  
  
end