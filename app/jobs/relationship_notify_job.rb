class RelationshipNotifyJob
  @queue = :notifications
  
  def self.perform(id)
    r = Relationship.find(id)
    r.deliver_notification
 
  # allow record not found to silently fail and log
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.info "RelationshipNotifyJob: Unable to send notification for relationship #{id} object no longer exists: #{e}"
  end
end
