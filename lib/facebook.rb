class Facebook
  class InvalidAccessTokenError < Exception; end
  
  def initialize(user)
    @user = user
  end
  
  def photo
    with_client { client.get_picture("me", :type => "large")}
  end
  
  # returns array of friend hashes
  def friends
    with_client do
      friends = []
      results = client.get_connections("me", "friends")
      begin
        friends += results
        results = results.next_page
      end while results
      friends
    end
  end
  
private
  def with_client(&block)
    begin
      yield
    rescue Koala::Facebook::APIError => e
      if e.message =~ /OAuthException/ 
        @user.update_attribute(:facebook_access_token, nil)
        raise InvalidAccessTokenError, e.message
      end
      raise
    end
  end
  
  def client
    Koala::Facebook::GraphAPI.new(@user.facebook_access_token)
  end
end