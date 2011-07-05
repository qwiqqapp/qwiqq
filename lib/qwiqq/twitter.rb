module Qwiqq
  module Twitter
    def self.share_deal(deal)
      # TODO share...
      deal.update_attribute(:shared_to_twitter_at, Time.now)
    end
  end
end