class Like < ActiveRecord::Base
  belongs_to :deal, :counter_cache => true
  belongs_to :user
  
  validates_presence_of :deal, :user
  
  default_scope :order => 'likes.created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  
  after_create :indextank_sync
  after_destroy :indextank_sync
  
  after_commit :async_deliver_notification, :if => :persisted?
  
  def indextank_sync
    deal.indextank_doc.sync_variables
  end
  
  def deliver_notification
    return unless notification_sent_at.nil?       # avoid double shares
    return unless deal.user.send_notifications    # only send if user has notifications enabled
    
    Mailer.deal_liked(deal.user, self).deliver
    update_attribute(:notification_sent_at, Time.now)
  end
  
  def async_deliver_notification
    Resque.enqueue(LikeNotifyJob, self.id)
  end
end
