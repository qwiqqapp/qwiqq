require "active_record_strip_attrs_extension"
require "date_helper"
require "paperclip_remote_file"

module Qwiqq
  # application-wide redis client
  mattr_accessor :redis
  
  def self.default_share_deal_message
    "I shared something I love on Qwiqq!"
  end

  def self.build_share_deal_message(message, deal, length = 140)
    deal_url = Rails.application.routes.url_helpers.deal_url(deal, :host => "qwiqq.me")
    remaining_length = length - (message.length + deal_url.length + 1)
    message += " #{deal.name.truncate(remaining_length)} #{deal_url}"
    message
  end

  def self.friendly_token(size = 20)
    SecureRandom.base64(size).gsub(/[^0-9a-z"]/i, '')
  end
  
  def self.foursquare_client
    Skittles.client
  end

  def self.convert_foursquare_category(foursquare_category_name)
    self.foursquare_categories[foursquare_category_name]
  end

  def self.foursquare_categories
    @foursquare_categories ||= YAML.load_file(Rails.root.join("config", "foursquare_categories.yml"))
  end

  def self.default_category
    Category.first
  end

  def self.email?(value)
    begin
      m = Mail::Address.new(value)
      # We must check that value contains a domain and that value is an email address
      r = m.domain && m.address == value
      t = m.__send__(:tree)
      # We need to dig into treetop
      # A valid domain must have dot_atom_text elements size > 1
      # user@localhost is excluded
      # treetop must respond to domain
      # We exclude valid email values like <user@localhost.com>
      # Hence we use m.__send__(tree).domain
      r &&= (t.domain.dot_atom_text.elements.size > 1)
    rescue Exception => e   
      r = false
    end
    r
  end
end
