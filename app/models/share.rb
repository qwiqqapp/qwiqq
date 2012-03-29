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
    user.facebook_client.share_link(self)
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
  

  
  private
  # [sender:] <personal comment> <deal.name> <deal.price> @ [deal.foursquare_venue_name] <deal_url>
  # Twitter: Yummy! The best bubble tea ever! @ Happy Teahouse http://qwiqq.me/posts/2259
  # Foursquare: Yummy! The best bubble tea ever! $5.99 http://qwiqq.me/posts/2259
  # SMS: Adam: Yummy! The best bubble tea ever! $5.99 @ Happy Teahouse http://qwiqq.me/posts/2259
  def build_message
    return unless service =~ /sms|twitter|foursquare/
    base = message_base
    meta = message_meta
    self.message = "#{base.truncate(138 - meta.length)} #{meta}"
  end
  
  # construct message base string, example: Yummy! The best bubble tea ever!
  def message_base
    base = ""
    base << "#{self.user.username}: " if service == "sms"
    base << "#{self.message} " unless self.message.blank?
    base << "#{deal.name}"
  end
  
  # construct message meta string, example: $5.99 @ Happy Teahouse http://qwiqq.me/posts/2259
  def message_meta
    url = Rails.application.routes.url_helpers.deal_url(self.deal, :host => "qwiqq.me")
    meta = deal.price_as_string || ""
    if deal.foursquare_venue_name && service != "foursquare"
      meta << " @ #{deal.foursquare_venue_name}"
    end
    meta << " #{url}"
  end
end

