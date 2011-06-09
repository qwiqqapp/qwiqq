class Comment < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user

  validates_presence_of :deal, :user, :body
  
  default_scope :order => 'created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}

  after_create :deliver_notification
  after_create :increment_comment_count
  after_destroy :decrement_comment_count

  private
  def deliver_notification
    Notifications.deal_commented(self).deliver
  end

  def increment_comment_count
    Deal.increment_counter(:comment_count, deal_id)
  end
   
  def decrement_comment_count
    Deal.decrement_counter(:comment_count, deal_id)
  end
end
