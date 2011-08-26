class IndextankSyncJob
  @queue = :indextank
  
  def self.perform(id)
    deal = Deal.find(id)
    deal.indextank_sync
  end
end