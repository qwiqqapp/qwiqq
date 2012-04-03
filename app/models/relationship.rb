class Relationship < ActiveRecord::Base
  belongs_to :user, :touch => true, :counter_cache => :following_count
  belongs_to :target, :touch => true, :class_name => "User", :counter_cache => :followers_count
  has_many :events, :class_name => "UserEvent"
  
  after_commit :async_deliver_notification, :on => :create
  after_commit :create_event, :on => :create
  
  before_destroy :remove_feedlets
  
  def deliver_notification
    
    # email notification
    return unless notification_sent_at.nil?    # avoid double notification
    return unless target.send_notifications    # only send if user has notifications enabled
    Mailer.new_follower(target, user).deliver
    
    update_attribute(:notification_sent_at, Time.now)
  end
  
  
  def async_deliver_notification
    Resque.enqueue(RelationshipNotifyJob, self.id)
  
  # rescue from connection error
   rescue Exception => e
     Rails.logger.error "Relationship#async_deliver_notification Failed: #{e.message}"
     notify_airbrake(e)
  end
  
  def create_event
    events.create(
      :event_type => "follower",
      :user => target,
      :created_by => user)
  end
  
  private
  def remove_feedlets
    Feedlet.where(user_id: user.id, posting_user_id: target.id).destroy_all
  end
  
  def friends?
    @friends ||= user.friends?(target)
  end
end
