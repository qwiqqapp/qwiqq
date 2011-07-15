class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :class_name => "User"
  
  after_create :deliver_notifications
  after_create :update_counts_create  
  before_destroy :update_counts_destroy
  
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
    
    def deliver_notifications
      return unless target.send_notifications
      
      if friends?
        Mailer.new_friend(target, user).deliver
      else
        Mailer.new_follower(target, user).deliver
      end
    end
end
