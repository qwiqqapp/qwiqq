module Qwiqq
  module FacebookSharing
    extend ActiveSupport::Concern

    module InstanceMethods
      def share_deal_to_facebook(deal)
        # post url 
        deal_url = Rails.application.routes.url_helpers.deal_url(deal, 
          :host => "production.qwiqq.com")

        # post caption
        caption = 
          if deal.user == self
            "I shared a deal on Qwiqq!"
          else
            "I found a deal on Qwiqq!"
          end
        
        # post to the users wall
        facebook_client.put_wall_post(
          caption,
          "name" => deal.name,
          "link" => deal_url,
          "picture" => deal.photo.url(:iphone_grid))
      end
    end
  end
end
