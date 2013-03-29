require "open-uri"

# TODO this class should be split using STI
class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :deal, :counter_cache => true, :touch => true
  has_many :events, :class_name => "UserEvent"


  validates :service, :inclusion => [ "email", "twitter", "facebook", "sms", "foursquare", "constantcontact"]

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
      deliver_to_mail
    end
  end
  
  def deliver_to_facebook
    #no share message
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
    puts "deliver_to_twitter TWITTER DELIVER"
    user.twitter_client.update(message)
    puts "deliver_to_twitter TWITTER DELIVER - SUCCESS"
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
  
  def deliver_to_mail
    Mailer.share_deal(email, self).deliver
    # update record
    update_attribute(:shared_at, Time.now)
  end
  
  # construct message base string, example: Hey I just shared this The best bubble tea ever! $5.99 @ Happy Teahouse http://qwiqq.me/posts/2259  
  def fb_share_message
    c = formatted_message
    c
  end

  # rescue from connection error
  def async_deliver
    Resque.enqueue(ShareDeliveryJob, self.id)

  rescue Exception => e
    Rails.logger.error "Share#async_deliver Failed: #{e.message}"
    notify_airbrake(e)
  end
  
  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new Qwiqq.twilio_sid, Qwiqq.twilio_auth_token
  end
  
  def create_event
    return unless [ "twitter", "facebook", "foursquare", "sms", "email", "constantcontact"].include?(service)
    
    events.create(
      :event_type => "share",
      :user => deal.user,
      :deal => deal,
      :created_by => user,
      :metadata => { :service => service })
  end
  
  # messages for posts without coupons - DEPRECATED
  # [sender:] <personal comment> <deal.name> <deal.price> @ [deal.foursquare_venue_name] <deal_url>
  # Twitter:    sweet - The best bubble tea ever! Buy Now: $5.99 @ Happy Teahouse http://qwiqq.me/posts/2259
  # Foursquare: sweet - The best bubble tea ever! Buy Now: $5.99 http://qwiqq.me/posts/2259
  # SMS: Adam:  sweet - The best bubble tea ever! Buy Now: $5.99 @ Happy Teahouse http://qwiqq.me/posts/2259
  
  # messages for coupons (if post.coupon?)
  # Twitter:    sweet - Qwiqq Coupon! The best bubble tea ever! #coupon @ Happy Teahouse http://qwiqq.me/posts/2259
  # Foursquare: sweet - Qwiqq Coupon! The best bubble tea ever! #coupon $5.99 http://qwiqq.me/posts/2259
  # SMS: Adam:  sweet - Qwiqq Coupon! The best bubble tea ever! #coupon $5.99 @ Happy Teahouse http://qwiqq.me/posts/2259
  
  
  #<optional message> <post name> #shopsmall BUY NOW <price> <url link>
  def formatted_message
    puts 'TESTING FORMATTED MESSAGE FOR APP SHARE'
    message = ""
    message << "@#{self.user.username} sent you a Qwiqq post: " if service == "sms"
    message << "#{self.message} - " unless self.message.blank?
    message << "#{deal.name} "
    message << "#shopsmall " if service == "twitter"
    if deal.for_sale_on_paypal 
      if deal.num_left_for_sale > 0
        message << "BUY NOW " 
      elsif deal.num_left_for_sale == 0
        message << "SOLD OUT " 
      end
    end
    message << "#{deal.price_as_string} " || ""
    unless service == "email"
      url = Rails.application.routes.url_helpers.deal_url(self.deal, :host => "qwiqq.me")
      message << "#{url}"     
    end
    if service == "sms" && !self.message.blank? && message.length > 150
      puts "BEFORE TRUNCATE SMS:#{message}"
      message[self.message] = "#{self.message.truncate(self.message.length - (message.length - 150))}"
      puts "TRUNCATED SMS:#{message}"
    end
    message = message.truncate(145)
    message
  end
  
  private
  def build_message
    return unless service =~ /sms|twitter|foursquare|email|constantcontact/
    self.message = formatted_message
    puts "build_message - SHARE MESSAGE:#{self.message}"
  end
  
  # construct message base string, example: Yummy! The best bubble tea ever! - DEPRECATED THIS ISN"T NEEDED ANYMORE"
  def message_base
    base = ""
    base << "@#{self.user.username}: " if service == "sms"
    base << "#{self.message} - " unless self.message.blank?

    base << "" if deal.for_sale_on_paypal
    base << "Qwiqq Coupon! " if self.deal.coupon?
    base << "#{deal.name}"
  end
  
  # construct message meta string, example: $5.99 @ Happy Teahouse http://qwiqq.me/posts/2259 - DEPRECATED THIS ISN"T NEEDED ANYMORE"
  def message_meta
    url = Rails.application.routes.url_helpers.deal_url(self.deal, :host => "qwiqq.me")
    meta = ''
    if deal.for_sale_on_paypal 
      if deal.num_left_for_sale > 0
        meta << "BUY NOW " 
      elsif deal.num_left_for_sale == 0
        meta << "SOLD OUT " 
      end
    end
    meta << deal.price_as_string || ""

    meta << " #{url}" unless service == 'email'# || service == 'twitter' || service == 'sms' || service == 'foursquare'
    #if Rails.env.production?
    #  meta << " #{shorten_with_bitly(url)}"  if service == 'twitter' || service == 'sms' || service == 'foursquare'
    #end
    meta
  end
  
  def shorten_with_bitly(url)
    # build url to bitly api
    user = "qwiqq2012"
    apikey = "R_452bcdeefba08c4ec065d62469b2082d"
    version = "2.0.1"
    bitly_url = "http://api.bit.ly/shorten?version=#{version}&longUrl=#{url}&login=#{user}&apiKey=#{apikey}"

    # parse result and return shortened url
    buffer = open(bitly_url, "UserAgent" => "Ruby-ExpandLink").read
    result = JSON.parse(buffer)
    short_url = result['results'][url]['shortUrl']
  end
  
end

