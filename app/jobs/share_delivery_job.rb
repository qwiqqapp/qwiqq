class ShareDeliveryJob
  @queue = :shares
  
  def self.perform(share_id)
    share = Share.find(share_id)
    share.deliver
  end
end