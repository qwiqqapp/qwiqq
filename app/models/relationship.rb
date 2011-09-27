class Relationship < ActiveRecord::Base
  belongs_to :user, :touch => true, :counter_cache => :following_count
  belongs_to :target, :touch => true, :class_name => "User", :counter_cache => :followers_count
  
  after_create :update_counts
  after_destroy :update_counts
  
  after_commit :async_deliver_notification, :on => :create
  
  def deliver_notification
    if friends?
      target.send_push_notification("#{self.user.username} is now your friend", "users/#{self.user.id}")
    else
      target.send_push_notification("#{self.user.username} is now following you", "users/#{self.user.id}")
    end

    return unless notification_sent_at.nil?    # avoid double notification
    return unless target.send_notifications    # only send if user has notifications enabled
    
    if friends?
      Mailer.new_friend(target, user).deliver
    else
      Mailer.new_follower(target, user).deliver
    end
    
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

  private
  def friends?
    @friends ||= user.friends?(target)
  end
end
