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
    picture = share.deal.photo.url(:iphone_zoom)
    target  = share.facebook_page_id.blank? ? "me" : share.facebook_page_id
    
    #original
    #client.put_connections(target, "links", {link: link, message: share.message})
    
    client.put_connections(target, "links", :message => share.message, :link => link)
    picture = Koala::UploadableIO.new("http://s3.amazonaws.com/qwiqq.images.production/deals/7255/iphone_zoom_2x.jpg?1346215620")
    client.put_picture('http://foodtreeimg.s3.amazonaws.com/uploaded_images/D-4df3adeeef87650001000007/20120509112048_image_600.jpg', { "message" => "This is the photo caption" })
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
    Koala::Facebook::GraphAPI.new(@user.facebook_access_token)
  end
  
  def logger
    Rails.logger
  end
end