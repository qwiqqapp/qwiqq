module Qwiqq
  module TwitterSharing
    extend ActiveSupport::Concern

    module InstanceMethods
      def share_deal_to_twitter(deal)
        # url for the post
        deal_url = Rails.application.routes.url_helpers.deal_url(deal, 
          :host => "www.qwiqq.me")

        # build the message
        message = Qwiqq.share_deal_message(deal, self)
        message = "#{message} #{deal_url}"

        # post update
        twitter_client.update(message)
      end
    end
  end
end
