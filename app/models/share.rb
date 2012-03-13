require "open-uri"

# TODO this class should be split using STI
class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :deal, :counter_cache => true, :touch => true
  has_many :events, :class_name => "UserEvent"

  validates :service, :inclusion => [ "email", "twitter", "facebook", "sms", "foursquare" ]

  before_create :build_message
  
  # avoids deliver being called before record has been persisted (possible with after_create)
  # ref: http://blog.nragaz.com/post/806739797/using-and-testing-after-commit-callbacks-in-rails-3
  after_commit :async_deliver, :if => :persisted?, :on => :create
  after_commit :create_event, :on => :create

  HOST = "staging.qwiqq.me"

  def deliver
    return unless shared_at.nil? # avoid double shares
    
    case service
    when "facebook"
      deliver_to_facebook
    when "twitter"
      deliver_to_twitter
    when "sms"
      deliver_sms
    when "foursquare"
      deliver_to_foursquare
    when "email"
      Mailer.share_deal(email, self).deliver
    end
  end

  
  def deliver_to_facebook
    # old
    deal_url = Rails.application.routes.url_helpers.deal_url(self.deal, :host => HOST)
    target_id = self.facebook_page_id.blank? ? "me" : self.facebook_page_id
    self.user.facebook_client.put_connections(target_id, "links", {:link => deal_url, :message => message})
    
    # new
    # user.facebook.share(self)
    
    # update
    self.update_attribute(:shared_at, Time.now)
  end

  def deliver_to_foursquare
    # if a venue id is present, checkin otherwise 'shout'
    if deal.foursquare_venue_id.blank?
      user.foursquare_client.add_checkin("public", { :shout => message })
    else
      checkin = user.foursquare_client.add_checkin(
        "public", { :venueId => deal.foursquare_venue_id, :shout => message })

      image_uri = URI.parse(deal.photo.url(:iphone_zoom_2x))
      open(image_uri) do |remote|
        photo = Tempfile.new("open-uri")
        photo.binmode
        photo.write(remote.read)
        photo.flush
        user.foursquare_client.add_photo(
          photo.path, 
          :checkinId => checkin["id"], 
          :venueid => deal.foursquare_venue_id)
      end
    end

    # update
    update_attribute(:shared_at, Time.now)
  end

  def deliver_to_twitter
    # post update
    user.twitter_client.update(message)

    # update record
    update_attribute(:shared_at, Time.now)
  end

  def deliver_sms
    # post update
    twilio_client.account.sms.messages.create(
      :from => Qwiqq.twilio_from_number,
      :to => number,
      :body => message)

    # update record
    update_attribute(:shared_at, Time.now)
  end

  def facebook_share?
    self.service == "facebook"
  end

  def async_deliver
    Resque.enqueue(ShareDeliveryJob, self.id)
  end
  
  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new Qwiqq.twilio_sid, Qwiqq.twilio_auth_token
  end
  
  def create_event
    # only create events for shares to networks
    return unless [ "twitter", "facebook", "foursquare" ].include?(service)
    
    events.create(
      :event_type => "share",
      :user => deal.user,
      :deal => deal,
      :created_by => user,
      :metadata => { :service => service })
  end

  def build_message
    self.message ||= Qwiqq.default_share_deal_message
    # append the name and url for twitter, sms and foursquare
    case service
    when "sms"
      self.message = Qwiqq.build_share_deal_message(self.message, deal, 160)
      self.message = "#{user.username}: #{self.message}"
    when "twitter", "foursquare"
      self.message.gsub!(/qwiqq/i, "@Qwiqq") if service == "twitter"
      self.message = Qwiqq.build_share_deal_message(self.message, deal, 140)
    end
  end
end

