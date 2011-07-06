module Qwiqq
  module IndexTank
        
        
    # TODO rescue from exception
    def self.add(deal)
      index.document(deal.id).add({:name        => deal.name,
                                   :created_at  => deal.created_at,
                                   :lat         => 
                                   :long        => 
                                   :category})
    end
    
    private
    def client
      @client = IndexTank::Client.new(ENV['INDEXTANK_API_URL'])
    end
    
    def index
      @index = client.indexes('deals')
    end
  end
end