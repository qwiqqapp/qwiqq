class LikeNotifyJob
  @queue = :notifications
  
  def self.perform(id)
    l = Like.find(id)
    l.deliver_notification
  end
end