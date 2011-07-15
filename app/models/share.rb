class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :deal

  after_create :deliver!

  validates :service, :inclusion => [ "email", "twitter", "facebook" ]

  def deliver!
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
end

