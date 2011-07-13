#  TODO: add faceting if required: http://indextank.com/documentation/tutorial-faceting

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
    extend ActiveSupport::Concern 
    
    module ClassMethods
      def indextank_search(query,type,opts={})
        Document.search(query,type,opts)
      end
    end
    
    module InstanceMethods
      def indextank_doc
        Document.new(self)
      end
    end
    
    # -----------------------
    class Document
      extend ActionView::Helpers::DateHelper
      
      attr_accessor :deal
      
      def initialize(deal)
        @deal = deal
      end
      
      # will raise exception if fails to add document
      def add
        Document.index.document(deal.id).add(fields, :variables => variables)
        deal.update_attribute(:indexed_at, Time.now)
        
      rescue IndexTank::InvalidArgument => e
        puts "Unable to add deal #{deal.id} to indextank: #{e.message}"
      end
      
      def remove
        Document.index.document(deal.id).delete
        deal.update_attribute(:indexed_at, nil)
      end
      
      def sync_variables
        Document.index.document(deal.id).update_variables(variables)
      end
      
      def fields
        fields = { :text         => deal.name,
                   :category     => deal.category.name,
                   :image        => deal.photo.url(:iphone_list),
                   :image_2x     => deal.photo.url(:iphone_list_2x),
                   :timestamp    => deal.created_at.to_i}
         
         # conditionals
         fields[:price]   = deal.price    if deal.price
         fields[:percent] = deal.percent  if deal.percent
         fields[:premium] = deal.premium  if deal.premium
         fields
      end
      
      def variables
        { 0 => deal.lat,
          1 => deal.lon,
          2 => deal.like_count }
      end


      def self.search(query,type,opts={})
        # change query for search by category
        search_opts = {:fetch => "text,image,image_2x,price,percent,premium,timestamp"}
        
        # select function based on type, assign lat and long
        search_opts[:function] = case type
          when 'nearby' 
            raise 'Location required, both lat and long' unless opts[:lat] && opts[:long]
            search_opts[:var0], search_opts[:var1] = opts[:lat], opts[:long]            
            1
          when 'category'
            query = "category:#{query}"
            if opts[:lat] && opts[:long]
              search_opts[:var0], search_opts[:var1] = opts[:lat], opts[:long]
              1
            else
              0
            end
          when 'popular'
            2
          else
            0
        end
        
        clean(index.search(query, search_opts)['results'])
      end
      
      def self.sync_functions
        functions.each_with_index{|f, i| index.functions(i, f).add }
      end
      
      private
      # replace indextank result keys with qwiqq keys
      def self.clean(results)
        results.map do |r| 
          { :deal_id    => r['docid'],
            :name       => r['text'],
            :image      => r['image'],
            :image_2x   => r['image_2x'],
            :price      => r['price'],
            :percent    => r['percent'],
            :premium    => r['premium'],
            :age        => (r['timestamp'] ? distance_of_time_in_words(Time.now.to_i, r['timestamp'].to_i) : ""),
            :score      => r['query_relevance_score']
          }
        end
      end
      
   
      def self.functions
        ["-age * relevance",                      # 0 Newest: newest and most relevant
         "-miles(d[0], d[1], q[0], q[1])",        # 1 Nearby: location
         "relevance * log(doc.var[2])" ]  # 2 Popular: like_count with age
      end
      
      def self.client
        @client = IndexTank::Client.new(ENV['INDEXTANK_API_URL'])
      end

      def self.index
        @index = self.client.indexes('deals')
      end
    end
  end
end

