class Like < ActiveRecord::Base
  belongs_to :deal, :counter_cache => true, :touch => true
  belongs_to :user, :counter_cache => true, :touch => true
  
  validates_presence_of :deal, :user
  
  default_scope :order => 'likes.created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  
  after_commit :async_deliver_notification, :on => :create
  
  def deliver_notification
    deal.user.send_push_notification("#{self.user.name} liked your deal #{deal.name}", "deals/#{deal.id}")
    return unless notification_sent_at.nil?       # avoid double notification
    return unless deal.user.send_notifications    # only send if user has notifications enabled
    
    Mailer.deal_liked(deal.user, self).deliver
    update_attribute(:notification_sent_at, Time.now)
  end
  
  def async_deliver_notification
    Resque.enqueue(LikeNotifyJob, self.id)
  end
end
