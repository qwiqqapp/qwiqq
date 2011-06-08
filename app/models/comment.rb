class Comment < ActiveRecord::Base
  
  belongs_to :deal
  belongs_to :user

  validates_presence_of :deal, :user, :body
  
  default_scope :order => 'created_at desc'

  after_create :deliver_notification

  private
  def deliver_notification
    Notifications.deal_commented(self).deliver
  end

end
