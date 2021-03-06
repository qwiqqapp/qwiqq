class CommentNotifyJob
  @queue = :notifications
  
  def self.perform(id)
    c = Comment.find(id)
    c.deliver_notification
    
  # allow record not found to silently fail and log
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.info "CommentNotifyJob: Unable to send notification for comment #{id} object no longer exists: #{e}"
  end 
end
