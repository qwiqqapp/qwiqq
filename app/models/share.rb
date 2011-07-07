class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :deal

  after_create :share_deal!

  private
    def share_deal!
      case service
      when "facebook" 
        Qwiqq::Facebook.share_deal(deal)
      when "twitter" 
        Qwiqq::Twitter.share_deal(deal)
      when "email"
        Mailer.share_deal(deal, email)
      end
    end
end
