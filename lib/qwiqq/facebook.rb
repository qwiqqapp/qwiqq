module Qwiqq
  module Facebook
    def self.share_deal(deal)
      # TODO share...
      deal.update_attributes(:shared_to_facebook_at, Time.now)
    end
  end
end