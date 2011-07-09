module Qwiqq
  module Facebook
    def share_to_facebook
      # url for the post
      deal_url = Rails.application.routes.url_helpers.deal_url(self, 
        :host => "production.qwiqq.com")

      # post to the users wall
      user.facebook_client.put_wall_post( 
        "I shared a deal on Qwiqq!",
        "name" => name,
        "link" => deal_url,
        "picture" => photo.url(:iphone_grid))
    end
  end
end
