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

  module IndexTank
    class Document
      attr_accessor :id, :fields, :variables, :categories
      
      def initialize(deal)
        @id         = deal.id
        @fields     = fields(deal)
        @variables  = variables(deal)
        @categories = categories(deal)
      end
    
      def add
        index.document(id).add(fields, :variables => variables)
        index.document(id).update_categories(categories)        
      end
      
      def remove
        index.document(id).remove
      end
      
      def sync_likes(like_count)
        index.document(id).update_variables({ 2 => like_count })
      end
      
      private
      def fields(deal)
        {:text         => deal.name,
         :price        => deal.price,
         :image        => deal.photo.url(:iphone_list),
         :image_2x     => deal.photo.url(:iphone_list_2x),
         :timestamp    => deal.created_at.to_i}
      end

      def variables(deal)
        { 0 => deal.lat,
          1 => deal.lon,
          2 => deal.like_count }
      end

      def categories(deal)
        { :cat => category.name }
      end
      
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

