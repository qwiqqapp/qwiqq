class Facebook
  
  def initialize(opts={})
  end
  
  def post
  end
  
  def friends
  end
  
  def photo
  end
  
  
  private
  def facebook_client
    @facebook_client ||= Koala::Facebook::GraphAPI.new(facebook_access_token) if facebook_access_token.present?
  end
end