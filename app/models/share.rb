class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :deal

  after_create :deliver!

  validates :service, :inclusion => [ "email", "twitter", "facebook" ]

  def deliver!
    case service
    when "facebook" 
      Qwiqq::Facebook.share_deal(deal)
    when "twitter" 
      Qwiqq::Twitter.share_deal(deal)
    when "email"
      Mailer.share_deal(deal, email).deliver
    end
    update_attribute(:shared_at, Time.now)
  end
end
