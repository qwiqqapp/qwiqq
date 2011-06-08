class Like < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user

  validates_presence_of :deal, :user

  default_scope :order => 'created_at desc'

  after_create :deliver_notification

  private
  def deliver_notification
    Notifications.deal_liked(self).deliver
  end
end
