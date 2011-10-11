class LocateDealJob
  @queue = :locate_deal
  
  def self.perform(id)
    deal = Deal.find(id) rescue nil
    deal.locate! if deal
  end
end

