module Qwiqq
  module TwitterSharing
    extend ActiveSupport::Concern

    module InstanceMethods
      def share_deal_to_twitter(deal)
        # url for the post
        

        # build the message
        message = Qwiqq.twitter_message(deal, self)
        # post update
        twitter_client.update(message)
      end
    end
  end
end
