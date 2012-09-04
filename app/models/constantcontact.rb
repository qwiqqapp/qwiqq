class Constantcontact < ActiveRecord::Base
  belongs_to :user

  after_create :deliver!

  validates :service, :inclusion => [ "email" ]

  def deliver!
    case service
    when "email"
      return unless user.send_notifications    # only send if user has notifications enabled
      Mailer.constant_contact(user).deliver
    end
  end
end
