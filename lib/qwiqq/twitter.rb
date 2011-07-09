module Qwiqq
  module Twitter
    def share_to_twitter
      # url for the post
      deal_url = Rails.application.routes.url_helpers.deal_url(self, 
        :host => "production.qwiqq.com")

      # post update
      user.twitter_client.update("I shared a deal on Qwiqq! #{deal_url}")
    end
  end
end