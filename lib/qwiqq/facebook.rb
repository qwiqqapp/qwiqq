module Qwiqq
  module Facebook
    def self.share_deal(deal)
      return unless deal.shared_to_facebook_at.blank?
      
      client = client_for_user(deal.user)
      client.put_wall_post( 
        "I shared a deal on Qwiqq - #{deal.name}",
        "name" => deal.name,
        "link" => deal_url(deal),
        "picture" => deal.photo.url(:admin_med))

      deal.update_attributes(:shared_to_facebook_at, Time.now)
    end

    def self.client_for_user(user)
      Koala::Facebook::GraphAPI.new(user.facebook_access_token)
    end

    def self.deal_url(deal)
      Rails.application.routes.url_helpers.deal_url(deal, :host => "qwiqq.me")
    end
  end
end