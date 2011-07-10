# search query = deal name with distance
# browse query = with category distance order

#response - deal mapping:
# text == name
# price 
# image
# image_2x
# timestamp (4min ago)
# like_count == variable 2
# deal_id == docid
# created_at.to_i == timestamp

# scoring fucntions/relevance
# distance

module Qwiqq
  module Indextank
    
    # attach document class to owner
    def indextank
      @doc = Document.new(self)
    end
    
    class Document
      attr_accessor :deal
      
      def initialize(deal)
        @deal = deal
      end
      
      # will raise exception if fails to add document
      def add
        index.document(deal.id).add(fields, :variables => variables)
        index.document(deal.id).update_categories(categories)
        deal.update_attribute(:indexed_at, Time.now)
        
      rescue IndexTank::InvalidArgument => e
        puts "Unable to add deal #{deal.id} to indextank: #{e.message}"
      end
      
      def remove
        index.document(deal.id).delete
        deal.update_attribute(:indexed_at, nil)
      end
      
      def sync_variables
        index.document(deal.id).update_variables(variables)
      end
      
      def fields
        fields = { :text         => deal.name,
                   :image        => deal.photo.url(:iphone_list),
                   :image_2x     => deal.photo.url(:iphone_list_2x),
                   :timestamp    => deal.created_at.to_i}
         
         # conditionals
         fields[:price]   = deal.price    if deal.price
         fields[:percent] = deal.percent  if deal.percent
         fields
      end

      def variables
        { 0 => deal.lat,
          1 => deal.lon,
          2 => deal.like_count }
      end

      def categories
        { :cat      => deal.category.name,
          :premium  => deal.premium.to_s  }
      end
      



      private
      def functions
        index.functions(0, '-age * relevance').add                  # Newest: newest and most relevant
        index.functions(1, "-miles(d[0], d[1], q[0], q[1])").add    # Nearby: location
        index.functions(2, "log(d.var[2]) - age/86400").add         # Popular: like_count with age
      end

      def client
        @client = IndexTank::Client.new(ENV['INDEXTANK_API_URL'])
      end

      def index
        @index = client.indexes('deals')
      end
      
      
    end
    
    
  end
end

