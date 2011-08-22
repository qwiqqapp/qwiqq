class LikeNotifyJob
  @queue = :notifications
  
  def self.perform(id)
    like = Like.find(id)
    like.deliver_notification
  end
end