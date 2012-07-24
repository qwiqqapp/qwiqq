class Facebook
  class InvalidAccessTokenError < Exception; end
  
  HOST = "qwiqq.me"
  
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
    
    #original
    #client.put_connections(target, "links", {link: link, message: share.message})
    
    client.put_connections(target, "links", :message => share.message, :link => link)
  end
  
  def me
    with_client do 
      client.get_object("me")
    end
  end
  
private
  def deal_share_url(deal)
    Rails.application.routes.url_helpers.deal_url(deal, :host => HOST)
  end

  def with_client(&block)
    begin
      yield
    rescue Koala::Facebook::APIError => e
      logger.error "[Rescue from] Koala::Facebook::APIError #{e.message}"
      case e.message 
        when /OAuthException/
          @user.update_column(:facebook_access_token, nil)
          raise InvalidAccessTokenError
      
        when /KoalaMissingAccessToken/
          raise InvalidAccessTokenError
      
        else
          raise
      end
    end
  end
  
  def client
    oauth = Koala::Facebook::OAuth.new('236767206341724', '2f51f0a009c7586de0267ad4df233499', 'http://qwiqq.me/')
    Koala::Facebook::GraphAPI.new(oauth.get_app_access_token)
  end
  
  def logger
    Rails.logger
  end
end