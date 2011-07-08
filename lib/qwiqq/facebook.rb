module Qwiqq
  module Facebook
    def self.share_deal(deal)
      client = client_for_user(deal.user)
      client.put_wall_post( 
        "I shared a deal on Qwiqq!",
        "name" => deal.name,
        "link" => deal_url(deal),
        "picture" => deal.photo.url(:iphone_grid))
    end

    def self.client_for_user(user)
      Koala::Facebook::GraphAPI.new(user.facebook_access_token)
    end

    def self.deal_url(deal)
      Rails.application.routes.url_helpers.deal_url(deal, :host => "production.qwiqq.com")
    end
  end
end