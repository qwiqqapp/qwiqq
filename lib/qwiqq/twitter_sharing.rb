module Qwiqq
  module TwitterSharing
    extend ActiveSupport::Concern

    module InstanceMethods
      def share_deal_to_twitter(deal)
        # url for the post
        deal_url = Rails.application.routes.url_helpers.deal_url(deal, 
          :host => "production.qwiqq.com")

        message = 
          if deal.user == self
            "I shared a deal on Qwiqq! #{deal_url}"
          else
            "I found a deal on Qwiqq! #{deal_url}"
          end

        # post update
        twitter_client.update(message)
      end
    end
  end
end