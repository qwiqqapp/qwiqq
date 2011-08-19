class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :deal

  validates :service, :inclusion => [ "email", "twitter", "facebook" ]

  # avoids deliver being called before record has been persisted (possible with after_create)
  # ref: http://blog.nragaz.com/post/806739797/using-and-testing-after-commit-callbacks-in-rails-3
  after_commit :async_deliver, :if => :persisted?
  
  def deliver
    return unless shared_at.nil?      # avoid double shares
    
    case service
    when "facebook"
      user.share_deal_to_facebook(deal)
    when "twitter"
      user.share_deal_to_twitter(deal)
    when "email"
      Mailer.share_deal(email, self).deliver
    end
    update_attribute(:shared_at, Time.now)
  end
  
  def async_deliver
    Resque.enqueue(ShareDeliveryJob, self.id)
  end
end