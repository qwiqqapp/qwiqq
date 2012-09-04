class Invitation < ActiveRecord::Base
  belongs_to :user

  after_create :deliver!

  validates :service, :inclusion => [ "email" ]

  def deliver!
    case service
    when "email"
      return unless user.send_notifications    # only send if user has notifications enabled
      Mailer.invitation(email, user).deliver
    end
    update_attribute(:delivered_at, Time.now)
  end
end
