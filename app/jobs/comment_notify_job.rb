class CommentNotifyJob
  @queue = :notifications
  
  def self.perform(id)
    comment = Comment.find(id)
    comment.deliver_notification
  end
end