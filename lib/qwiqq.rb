require "active_record_strip_attrs_extension"
require "nginx_content_length_fix"
require "qwiqq/facebook_sharing"
require "qwiqq/twitter_sharing"
require "qwiqq/sms_sharing"

module Qwiqq
  # application-wide redis client
  mattr_accessor :redis
  
  # TODO there might be a better place for this to live, it's currently used by;
  #  - mailer to construct the share_deal mail
  #  - twitter and facebook sharing messages via API
  #  - twitter and facebook sharing links via Web
  SHARING_PREFIXES = [ "Yay!", "Cool!", "Sweet!", "Nice!", "Awesome!", "Hurray!", "Check it out!" ]

  def self.random_sharing_prefix
    SHARING_PREFIXES[rand(SHARING_PREFIXES.size - 1)]
  end

  def self.share_deal_message(deal, sharer = nil)
    # pick a prefix at random
    message = 
      if sharer and sharer == deal.user
        "I shared a great deal on Qwiqq!"
      else
        "I found a great deal on Qwiqq!"
      end
    "#{random_sharing_prefix} #{message}"
  end

  def self.twitter_message(deal, sharer = nil, sms = nil)
    deal_url = Rails.application.routes.url_helpers.deal_url(deal, :host => "www.qwiqq.me")
    message = Qwiqq.share_deal_message(deal, sharer)
    
    remaining_length = 140
    if sms && sharer # include sharer's username for SMS
      remaining_length = 160
      message = "#{sharer.username}: #{message}"
    else
      message.gsub!(/qwiqq/i, "@Qwiqq") + " "
    end
    
    remaining_length = remaining_length - (message.length + deal_url.length + 1)
    message += "#{deal.name.truncate(remaining_length)} #{deal_url}"
    message
  end

  def self.friendly_token(size = 20)
    ActiveSupport::SecureRandom.base64(size).gsub(/[^0-9a-z"]/i, '')
  end
end

