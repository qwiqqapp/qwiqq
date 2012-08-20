class Like < ActiveRecord::Base
  belongs_to :deal, :counter_cache => true, :touch => true
  belongs_to :user, :counter_cache => true, :touch => true

  has_many :events, :class_name => "UserEvent", :dependent => :destroy
  
  validates_presence_of :deal, :user
  
  default_scope :order => 'likes.created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  
  after_commit :async_deliver_notification, :on => :create
  after_commit :create_event, :on => :create
  
  def deliver_notification
    return unless notification_sent_at.nil?       # avoid double notification
    return unless deal.user.send_notifications    # only send if user has notifications enabled
    
    return if deal.user.id == self.user.id
    Mailer.deal_liked(deal.user, self).deliver
    update_attribute(:notification_sent_at, Time.now)
  end
  
  def async_deliver_notification
    Resque.enqueue(LikeNotifyJob, self.id)
  end
  
  def create_event
    events.create(
      :event_type => "like",
      :deal => deal,
      :user => deal.user, 
      :created_by => user)
  end
end

