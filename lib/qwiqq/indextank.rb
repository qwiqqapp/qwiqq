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
      def indextank
        Document
      end
    end
    
    module InstanceMethods
      def indexed_doc
        Document.new(self)
      end
    end
    
    # -----------------------
    class Document
      attr_accessor :deal
      
      def initialize(deal)
        @deal = deal
      end
      
      # will raise exception if fails to add document
      def add
        self.index.document(deal.id).add(fields, :variables => variables)
        deal.update_attribute(:indexed_at, Time.now)
        
      rescue IndexTank::InvalidArgument => e
        puts "Unable to add deal #{deal.id} to indextank: #{e.message}"
      end
      
      def remove
        self.index.document(deal.id).delete
        deal.update_attribute(:indexed_at, nil)
      end
      
      def sync_variables
        self.index.document(deal.id).update_variables(variables)
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
      
      def self.browse(category, lat, long)
        search('browse', {:q => "category:#{category}", :lat => lat, :long => long})
      end

      def self.nearby(q, lat, long)
        search('nearby', {:q => q, :lat => lat, :long => long})
      end

      def self.newest(q)
        search('newest', {:q => q})
      end

      def self.popular(q)
        search('popular', {:q => q})
      end

      private
      def self.search(type, opts={})
        q = opts[:q]
        base = {:fetch => "text,image,image_2x,price,percent,premium"}
        
        function = case type
          when 'newest'         then {:function => 0}
          when /browse|nearby/  then {:function => 1, :var0 => opts[:lat], :var1 => opts[:long]}
          when 'popular'        then {:function => 2}
          else  
            {}
        end
        
        index.search(q, base.merge(function))['results']
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

