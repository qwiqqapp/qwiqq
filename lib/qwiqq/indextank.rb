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
        Document.index.document(deal.id).add(fields, :variables => variables, :categories => categories)
        deal.update_attribute(:indexed_at, Time.now)
        
      rescue IndexTank::InvalidArgument => e
        puts "Unable to add deal #{deal.id} to indextank: #{e.message}"
      end
      
      def remove
        Document.index.document(deal.id).delete
        deal.update_attribute(:indexed_at, nil)
      end
      
      def sync
        sync_variables
        sync_categories
      end
      
      def sync_variables
        Document.index.document(deal.id).update_variables(variables)
      end
      
      def sync_categories
        Document.index.document(deal.id).update_categories(categories)
      end
      
      def fields
        fields = { :text         => deal.name,
                   :category     => deal.category.name,
                   :image        => deal.photo.url(:iphone_list),
                   :image_2x     => deal.photo.url(:iphone_list_2x),
                   :timestamp    => deal.created_at.to_i,
                   :comment_count => deal.comments_count.to_i}
         
         # conditionals
         fields[:price]   = deal.price    if deal.price
         fields[:percent] = deal.percent  if deal.percent
         fields
      end
      
      def variables
        { 0 => deal.lat,
          1 => deal.lon,
          2 => deal.likes_count.to_i }
      end
      
      def categories
        { 'premium' => deal.premium.to_s }
      end
      
      def self.search(query,type,opts={})
        # change query for search by category
        search_opts = {:fetch => "text,image,image_2x,price,percent,premium,timestamp",     #selected fields to return
                       :fetch_variables => true,                                            # return all variables as variable_#
                       :fetch_categories => true,                                           # return all categories as category_<NAME>
                       :len => 40}                                                          # max results returned
        
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
          { :deal_id          => r['docid'],
            :name             => r['text'],
            :photo_list       => r['image'],
            :photo_list_2x    => r['image_2x'],
            :price            => r['price'],
            :percent          => r['percent'],
            :premium          => r['category_premium'],
            :age              => (r['timestamp'] ? distance_of_time_in_words(Time.now.to_i, r['timestamp'].to_i) : ""),
            :score            => r['query_relevance_score'],
            :like_count       => r['variable_2'].to_i,
            :comment_count    => r['comment_count'].to_i
          }
        end
      end
      
   
      def self.functions
        ["-age * relevance",                      # 0 Newest: newest and most relevant
         "-miles(d[0], d[1], q[0], q[1])",        # 1 Nearby: location
         "relevance * log(doc.var[2] + 1)" ]          # 2 Popular: like_count with age
      end
      
      def self.client
        @client = IndexTank::Client.new(ENV['INDEXTANK_API_URL'])
      end

      def self.index
        @index = client.indexes('deals')
      end
    end
  end
end

