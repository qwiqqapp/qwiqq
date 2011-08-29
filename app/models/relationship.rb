class Relationship < ActiveRecord::Base
  belongs_to :user, :touch => true, :counter_cache => :following_count
  belongs_to :target, :touch => true, :class_name => "User", :counter_cache => :followers_count
  
  after_create :update_counts
  after_destroy :update_counts
  
  after_commit :async_deliver_notification, :on => :create
  
  def deliver_notification
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
  
  
  private
    def friends?
      @friends ||= user.friends?(target)
    end
    
    def update_counts
      user.friends_count = user.friends.count
      target.friends_count = target.friends.count
      user.save
      target.save
    end
end
