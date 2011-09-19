module Qwiqq
  module SmsSharing
    extend ActiveSupport::Concern

    module InstanceMethods
      def share_deal_to_sms(deal, number)
        # url for the post
        

        # build the message
        message = Qwiqq.twitter_message(deal, self)
        # post update
        twilio_client.account.sms.messages.create(:from => Qwiqq.twilio_from_number,
                                                  :to => number,
                                                  :body => message)

      end

      def twilio_client
        @twilio_client ||= Twilio::REST::Client.new Qwiqq.twilio_sid, Qwiqq.twilio_auth_token
      end
    end
  end
end

