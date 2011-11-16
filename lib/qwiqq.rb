require "active_record_strip_attrs_extension"
require "foursquare"

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
      message.gsub!(/qwiqq/i, "@Qwiqq")
    end
    
    remaining_length = remaining_length - (message.length + deal_url.length + 1)
    message += " #{deal.name.truncate(remaining_length)} #{deal_url}"
    message
  end

  def self.friendly_token(size = 20)
    ActiveSupport::SecureRandom.base64(size).gsub(/[^0-9a-z"]/i, '')
  end
  
  def self.foursquare_client
    Foursquare.new(
      :client_id => ENV["FOURSQUARE_CLIENT_ID"], 
      :client_secret => ENV["FOURSQUARE_CLIENT_SECRET"])
  end

  def self.convert_foursquare_category(foursquare_category_name)
    self.foursquare_categories[foursquare_category_name]
  end

  def self.foursquare_categories
    @foursquare_categories ||= YAML.load_file(Rails.root.join("config", "foursquare_categories.yml"))
  end
end

