module Qwiqq
  module FacebookSharing
    extend ActiveSupport::Concern

    module InstanceMethods
      def share_deal_to_facebook(deal)
        # post url 
        deal_url = Rails.application.routes.url_helpers.deal_url(deal, 
          :host => "www.qwiqq.me")

        # post caption
        caption = Qwiqq.share_deal_message(deal, self)
        
        # post to the users wall
        facebook_client.put_wall_post(
          caption,
          "name" => deal.name,
          "link" => deal_url,
          "picture" => deal.photo.url(:iphone_grid))
      rescue Koala::Facebook::APIError
        facebook_access_token = nil
        self.save
      end
    end
  end
end
