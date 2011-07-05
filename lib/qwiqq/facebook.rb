module Qwiqq
  module Facebook
    def self.share_deal(deal)
      client = self.client_for_user(deal.user)

      #client.put_wall_post( 
      #  message, 
      #  "name" => options[:link_name], 
      #  "link" => options[:link], 
      #  "caption" => options[:caption], 
      #  "picture" => photo.thumbnail) 

      deal.update_attributes(:shared_to_facebook_at, Time.now)
    end

    def self.client_for_user(user)
      graph = Koala::Facebook::GraphAPI.new(user.facebook_access_token)
    end
  end
end