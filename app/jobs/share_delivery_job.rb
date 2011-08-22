class ShareDeliveryJob
  @queue = :shares
  
  def self.perform(share_id)
    s = Share.find(share_id)
    s.deliver
  end
end