class Facebook
  class InvalidAccessTokenError < Exception; end
  
  HOST = "staging.qwiqq.me"
  
  def initialize(user)
    @user = user
  end
  
  def photo
    with_client do 
      client.get_picture("me", :type => "large")
    end
  end
  
  # returns array of FB friend hashes
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
  
  # returns array of FB accounts
  def pages
    with_client do
      client.get_connections("me", "accounts")
    end
  end
  
  # can raise Koala::Facebook::APIError
  def share_link(share)
    link    = deal_share_url(share.deal)
    target  = share.facebook_page_id.blank? ? "me" : share.facebook_page_id
    
    client.put_connections(target, "links", {link: link, message: share.message})
  end
  
  def me
    with_client{ client.get_object("me") }
  end
  
private
  def deal_share_url(deal)
    Rails.application.routes.url_helpers.deal_url(deal, :host => HOST)
  end


  def with_client(&block)
    yield
    
  rescue Koala::Facebook::APIError => e
    case e.message 
      when /OAuthException/
        @user.update_attribute(:facebook_access_token, nil)
        raise InvalidAccessTokenError, e.message
      
      when /KoalaMissingAccessToken/
        raise InvalidAccessTokenError, e.message
      
      else
        raise
    end
  end
  
  def client
    Koala::Facebook::GraphAPI.new(@user.facebook_access_token)
  end
end