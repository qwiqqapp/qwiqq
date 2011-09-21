class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :deal

  validates :service, :inclusion => [ "email", "twitter", "facebook", "sms" ]

  # we share to facebook immediately so that we can provide the user with error messages
  before_create :deliver, :if => :facebook_share?

  # avoids deliver being called before record has been persisted (possible with after_create)
  # ref: http://blog.nragaz.com/post/806739797/using-and-testing-after-commit-callbacks-in-rails-3
  after_commit :async_deliver, :if => :persisted?, :unless => :facebook_share?

  HOST = "www.qwiqq.me"

  def deliver
    return unless shared_at.nil? # avoid double shares
    
    case service
    when "facebook"
      deliver_to_facebook
    when "twitter"
      deliver_to_twitter
    when "sms"
      deliver_sms
    when "email"
      Mailer.share_deal(email, self).deliver
    end
  end

  def deliver_to_facebook
    # post url 
    deal_url = Rails.application.routes.url_helpers.deal_url(deal, :host => HOST)

    # post caption
    caption = Qwiqq.share_deal_message(deal, self)
 
    # post to the users wall
    user.facebook_client.put_wall_post(caption,
      "name" => deal.name,
      "link" => deal_url,
      "picture" => deal.photo.url(:iphone_grid))

    self.shared_at = Time.now
  end

  def deliver_to_twitter
    # build the message
    message = Qwiqq.twitter_message(deal, user)

    # post update
    user.twitter_client.update(message)

    # update record
    update_attribute(:shared_at, Time.now)
  end

  def deliver_sms
    # build the message
    message = Qwiqq.twitter_message(deal, user) 

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
end

