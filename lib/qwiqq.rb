require "active_record_strip_attrs_extension"
require "date_helper"
require "paperclip_remote_file"
require "foursquare"

module Qwiqq
  # application-wide redis client
  mattr_accessor :redis
  
  def self.default_share_deal_message
    "I shared something I love on Qwiqq!"
  end

  def self.build_share_deal_message(message, deal, length = 140)
    deal_url = Rails.application.routes.url_helpers.deal_url(deal, :host => "www.qwiqq.me")
    remaining_length = length - (message.length + deal_url.length + 1)
    message += " #{deal.name.truncate(remaining_length)} #{deal_url}"
    message
  end

  def self.friendly_token(size = 20)
    SecureRandom.base64(size).gsub(/[^0-9a-z"]/i, '')
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
