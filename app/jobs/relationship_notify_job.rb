class RelationshipNotifyJob
  @queue = :notifications
  
  def self.perform(id)
    r = Relationship.find(id)
    r.deliver_notification
  end
end