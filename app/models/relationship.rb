class Relationship < ActiveRecord::Base
  belongs_to :user, :touch => true
  belongs_to :target, :class_name => "User"
  
  after_create :update_counts_create
  before_destroy :update_counts_destroy
  
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
    
    def update_counts_create
      user.increment(:following_count)
      target.increment(:followers_count)
      if friends?
        user.increment(:friends_count)
        target.increment(:friends_count)
      end
      user.save
      target.save
    end

    # TODO check for target = nil
    def update_counts_destroy
      user.decrement(:following_count)
      target.decrement(:followers_count)
      if friends?
        user.decrement(:friends_count)
        target.decrement(:friends_count)
      end
      user.save
      target.save
    end
    

end
