require "active_record_strip_attrs_extension"
require "qwiqq/facebook_sharing"
require "qwiqq/twitter_sharing"
require "qwiqq/indextank"

module Qwiqq
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

  def self.friendly_token(size = 20)
    ActiveSupport::SecureRandom.base64(size).gsub(/[^0-9a-z"]/i, '')
  end
end

