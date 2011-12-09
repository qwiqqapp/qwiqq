class Relationship < ActiveRecord::Base
  belongs_to :user, :touch => true, :counter_cache => :following_count
  belongs_to :target, :touch => true, :class_name => "User", :counter_cache => :followers_count
  has_many :events, :class_name => "UserEvent"
  
  after_create :update_counts
  after_destroy :update_counts
  
  after_commit :async_deliver_notification, :on => :create
  after_commit :create_event, :on => :create
  
  def deliver_notification
    # push notification
    target.send_push_notification("#{self.user.username} is now following you", "users/#{self.user.id}")

    # email notification
    return unless notification_sent_at.nil?    # avoid double notification
    return unless target.send_notifications    # only send if user has notifications enabled
    Mailer.new_follower(target, user).deliver
    
    update_attribute(:notification_sent_at, Time.now)
  end
  
  def async_deliver_notification
    Resque.enqueue(RelationshipNotifyJob, self.id)
  end
  
  def update_counts
    if user
      user.friends_count = user.friends.count
      user.save
    end
    
    if target
      target.friends_count = target.friends.count
      target.save
    end
  end

  def create_event
    events.create(
      :event_type => "follower",
      :user => target,
      :created_by => user)
  end

  private
  def friends?
    @friends ||= user.friends?(target)
  end
end
