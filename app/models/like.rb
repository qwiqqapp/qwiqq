class Like < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user
  
  validates_presence_of :deal, :user
  
  default_scope :order => 'likes.created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  
  after_create :deliver_notification
  after_create :increment_like_count
  after_destroy :decrement_like_count
  
  private
  def deliver_notification
    Notifications.deal_liked(self).deliver
  end

  def increment_like_count
    Deal.increment_counter(:like_count, deal_id)
  end
   
  def decrement_like_count
    Deal.decrement_counter(:like_count, deal_id)
  end
end
