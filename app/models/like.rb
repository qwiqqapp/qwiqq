class Like < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user
  
  validates_presence_of :deal, :user
  
  default_scope :order => 'created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  
  after_create :deliver_notification
  
  private
  def deliver_notification
    Notifications.deal_liked(self).deliver
  end
end
