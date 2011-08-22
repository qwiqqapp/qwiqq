class CommentNotifyJob
  @queue = :notifications
  
  def self.perform(id)
    c = Comment.find(id)
    c.deliver_notification
  end
end