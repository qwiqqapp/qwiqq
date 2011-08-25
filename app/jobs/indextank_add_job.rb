class IndextankAddJob
  @queue = :indextank
  
  def self.perform(id)
    deal = Deal.find(id)
    deal.indextank_add
  end
end