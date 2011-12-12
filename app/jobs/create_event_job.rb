class createEventJob
  @queue = :events
  
  def self.perform(id, type)
    
    
    

    l = Like.find(id)
    l.deliver_notification
 
  # allow record not found to silently fail and log
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.info "LikeNotifyJob: Unable to send notification for like #{id} object no longer exists: #{e}"
  end
end
