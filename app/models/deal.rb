# encoding: UTF-8
class Deal < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  
  MAX_AGE = 365*10
  MAX_SEARCH_AGE = 120
  MAX_RANGE = 40234   # default search range in metres (25 miles)
  COUPON_TAG = "#coupon"
  DEFAULT_COUPON_COUNT = 100
  
  define_index do
    indexes :name
    indexes :foursquare_venue_name
    indexes category(:name), :as => :category
    indexes :hidden
    has "RADIANS(lat)", :as => :lat_radians, :type => :float
    has "RADIANS(lon)", :as => :lon_radians, :type => :float
    
    set_property :latitude_attr => :lat_radians, :longitude_attr => :lon_radians

    has created_at, likes_count, comments_count, transactions_count, lat, lon
  end

  belongs_to :user, :counter_cache => true, :touch => true
  belongs_to :category
  
  has_many :comments, :dependent => :destroy
  has_many :transactions, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :shares
  has_many :liked_by_users, :through => :likes, :source => :user
  has_many :feedlets, :dependent => :destroy
  has_many :events, :class_name => "UserEvent", 
    :conditions => [ "event_type IN (?)", [ "comment", "like", "share", "sold" ] ], 
    :dependent => :destroy
  
  #TODO update to 3.1 and use role based attr_accessible for premium
  attr_accessible :name, 
                  :category_id, 
                  :price,
                  :lat, 
                  :lon, 
                  :photo, 
                  :premium, 
                  :location_name,
                  :foursquare_venue_id, 
                  :foursquare_venue_name,
                  :coupon,
                  :coupon_count,
                  :for_sale_on_paypal,   
                  :num_left_for_sale,  
                  :num_for_sale,    
                  :currency, 
                  :paypal_email,
                  :hidden,
                  :located,
                  :events_hidden
               
  
  # TODO update to 3.0 validates method
  validates_presence_of   :user, :category, :name, :message => "is required"
  validates_length_of     :name, :maximum => 70, :message=> "max characters is 70"
  validates_uniqueness_of :unique_token
  validates :price, presence: true, numericality:  true
  
  before_validation :store_unique_token!, :on => :create
  before_validation :set_coupon_attributes, :on => :create
  
  before_create :set_user_photo
  after_create :populate_feed
  after_create :async_locate
  after_save :after_save
  after_destroy :after_destroy
  
  scope :today, lambda { where("DATE(created_at) = ?", Date.today) }
  scope :recent, lambda { where("DATE(created_at) > ?", 30.days.ago) }
  scope :public, where(:hidden => false)
  scope :premium, where(:premium => true)
  scope :sorted, :order => "created_at desc"
  scope :popular, order("likes_count desc, comments_count desc")
  scope :coupon, where(:coupon => true)
  scope :most_shared, where(:premium => true)
    
  # all images are cropped
  # see initializers/auto_orient.rb for new processor
  #  TODO review all image sizes, need to reduce/reuse
  has_attached_file :photo, { 
    :processors => [:auto_orient, :thumbnail], 
    :styles => { 
      # app v2
      :iphone_explore => ['95x95#', :jpg],
      :iphone_explore_2x => ['190x190#', :jpg]  ,    
      
      # popular
      :iphone_grid => ["75x75#", :jpg],
      :iphone_grid_2x => ["150x150#", :jpg],
     
      # feed, browse, search list views
      :iphone_list => ["55x55#", :jpg],
      :iphone_list_2x => ["110x110#", :jpg],
     
      # deal detail view
      :iphone_profile => ["85x85#", :jpg],
      :iphone_profile_2x => ["170x170#", :jpg],
     
      # zoomed image size
      :iphone_zoom => ["300x300#", :jpg],
      :iphone_zoom_2x => ["600x600#", :jpg]
    }
  }.merge(PAPERCLIP_STORAGE_OPTIONS)

  def as_json(options={})
    options ||= {}

    json = {
      :deal_id        => id.try(:to_s),
      :name           => name,
      
      # popular
      :photo_grid     => photo.url(:iphone_grid),
      :photo_grid_2x  => photo.url(:iphone_grid_2x),
      
      # profile image on deal detail screen
      :photo_profile     => photo.url(:iphone_profile),
      :photo_profile_2x  => photo.url(:iphone_profile_2x),      
      
      # feed, browse and search
      :photo_list     => photo.url(:iphone_list),
      :photo_list_2x  => photo.url(:iphone_list_2x),
      
      # deal detail zoom
      :photo_zoom     => photo.url(:iphone_zoom),
      :photo_zoom_2x  => photo.url(:iphone_zoom_2x),

      # app v2
      :photo_explore  => photo.url(:iphone_explore),
      :photo_explore_2x => photo.url(:iphone_explore_2x),

      :user_photo     => user_photo,
      :user_photo_2x  => user_photo_2x,
      
      :distance       => sphinx_geo_distance(:miles),
      :score          => sphinx_geo_distance(:miles),   #legacy attribute from indextank should be deprecated
      
      :premium        => premium,
      :price          => price,
      
      :lat            => lat.try(:to_s),
      :lon            => lon.try(:to_s),
      
      :transaction_count  => transactions_count,
      :comment_count  => comments_count,
      :like_count     => likes_count,
      :age            => age_in_words.gsub("about ", ""),
      :short_age      => short_age_in_words,
      :location_name  => location_name,
      :venue_name     => foursquare_venue_name,
      :user_id        => user_id.try(:to_s),
      :repost_count   => reposts_count,
      :share_count    => shares_count,
      
      :for_sale_on_paypal      => for_sale_on_paypal,
      :currency               => currency,
      :hidden => hidden,
      #:number_users_shared    => number_users_shared,
      #:num_left_for_sale      => num_left_for_sale,
      #:num_for_sale           => num_for_sale,
      #:paypal_email           => paypal_email
    }
    
    if for_sale_on_paypal?
      json[:num_left_for_sale]  = num_left_for_sale
      json[:num_for_sale]       = num_for_sale
      #json[:currency]           = currency
      json[:paypal_email]       = paypal_email
    end
    
    # add 'liked' for the current user if requested
    current_user = options[:current_user]
    json[:liked] = current_user.liked_deals.include?(self) if current_user

    # add detail if requested
    unless options[:minimal]
      json[:category]       = category.try(:name)
      json[:events]         = events.limit(60)
      json[:comments]       = comments.limit(3)
      #Should transactions really be here? - this crashes it
      #json[:transactions]   = transactions.limit(3)
      json[:liked_by_users] = liked_by_users.limit(6)
      json[:user]           = user.try(:as_json, {:minimal=>true})
    end
    
    json
  end
  
  def sphinx_geo_distance(unit=nil)
    return nil unless self.sphinx_attributes && sphinx_attributes['@geodist']
    meters = self.sphinx_attributes['@geodist']
    case unit
      when :km    then meters / 1000
      when :miles then meters * 0.000621371192
      else
        meters
    end 
  end  
  
  def after_save
    if self.hidden_changed? && self.hidden == true
      puts "AFTER SAVE HIDDEN feedlets count:#{self.feedlets.count}"
      self.feedlets.destroy_all
      puts "DESTROY FEEDLETS count:#{self.feedlets.count}"
    end
  end
  
  def after_destroy 
    unless self.hidden
      puts "DESTROY:#{self.name}"
      puts "CURRENT user deals count:#{self.user.deals_num}"
      self.user.deals_num = self.user.deals_num - 1
      self.user.save!
      puts "NEW curernt user deals count:#{self.user.deals_num}"
    end
  end
  
  def price_as_string
    if self.price > 0
      if self.currency
        if !self.currency.empty?
          currencySymbol = number_to_currency(price.to_f / 100, :unit => self.currency)
          currencySymbol = currencySymbol.sub("AUD","AUD $").sub( "BRL", "R$" ).sub( "CAD", "CAD $" )
          currencySymbol = currencySymbol.sub("CZK","CZK").sub( "DKK", "DKK" ).sub( "EUR", "€" )
          currencySymbol = currencySymbol.sub("HKD","HK$").sub( "HUF", "HUF" ).sub( "ILS", "₪" )
          currencySymbol = currencySymbol.sub("JPY","¥").sub( "MYR", "MYR" ).sub( "MXN", "MX$" )
          currencySymbol = currencySymbol.sub("NOK","NOK").sub( "NZD", "NZ$" ).sub( "PHP", "Php" )
          currencySymbol = currencySymbol.sub("PLN","PLN").sub( "GBP", "£" ).sub( "SGD", "SGD" )
          currencySymbol = currencySymbol.sub("SEK","SEK").sub( "CHF", "CHF" ).sub( "TWD", "NT$" )
          currencySymbol = currencySymbol.sub("THB","฿").sub( "TRY", "TRY" ).sub( "USD", "$" )
        else
          number_to_currency(price.to_f / 100)
        end
      else
        number_to_currency(price.to_f / 100)
      end
    else
      "Free"
    end
  end

  def reduced_left_for_sale
    puts "reduced_left_for_sale:#{num_left_for_sale}"
    puts "ID:#{self.id}"
    if num_left_for_sale >= 1000000 #millions
      puts 'millions'
      millions = num_left_for_sale/1000000
      "#{millions.to_i}m"
    elsif num_left_for_sale >= 1000 #thousands
      puts 'thousands'
      thousands = num_left_for_sale/1000
      "#{thousands.to_i}k"
    else
      puts 'nothing special'
      num_left_for_sale
    end
  end
  
  def age_in_words
    created_at ? time_ago_in_words(created_at) : ""
  end

  def short_age_in_words
    created_at ? short_time_ago_in_words(created_at) : ""
  end
  
  # construct message base string, example: The best bubble tea ever! $5.99 @ Happy Teahouse http://qwiqq.me/posts/2259  DEPRECATED
  #new message - <post name> #shopsmall BUY NOW(if paypal) <price> <url link>
  def share_message
    meta = "#shopsmall "
    if self.for_sale_on_paypal 
      if self.num_left_for_sale > 0
        meta << "BUY NOW " 
      elsif self.num_left_for_sale == 0
        meta << "SOLD OUT " 
      end
    end
    meta << self.price_as_string if self.price
    meta << " #{Rails.application.routes.url_helpers.deal_url(self, :host => "qwiqq.me")}"
    t = "#{name.truncate(138 - meta.size)} #{meta}"
    t
  end
  
  def share_message_without_hashtag
    meta = ""
    if self.for_sale_on_paypal 
      if self.num_left_for_sale > 0
        meta << "BUY NOW " 
      elsif self.num_left_for_sale == 0
        meta << "SOLD OUT " 
      end
    end
    meta << self.price_as_string if self.price
    meta << " #{Rails.application.routes.url_helpers.deal_url(self, :host => "qwiqq.me")}"
    t = "#{name.truncate(138 - meta.size)} #{meta}"
    t
  end

  # Search deals.
  #
  # options:
  #   :query - The search term
  #   :category - Limit results to category
  #   :lat, :lon, :range - Limit results to range
  #   :limit - Limit the number of results
  #   :page - Pagination page
  #   :age - The maximum age (in days) of the deal
  #
  # Returns a ThinkingSphinx collection containing all deals matching the filters.
   def self.filtered_search(options={})
     puts "filtered_search"
  # bail early if the provided query is invalid
    return [] if options[:query] and options[:query].blank?

    lat, lon = options[:lat], options[:lon]
    raise NoMethodError, "Coordinates required" if lat.blank? && lon.blank? && options[:category] != "url"
    range = (options[:range] || 10_000).to_f
    # filtering options
    conditions = {}
    conditions[:category] = options[:category] unless options[:category].nil?

    with = {}
    with[:created_at] = options[:age].ago..Time.now unless options[:age].nil?

    search_options = {}

    if options[:category] != "url"
      with["@geodist"] = 0.0..range
      search_options[:order] = "@geodist ASC, @relevance DESC, created_at DESC"
    else
      search_options[:order] = "created_at desc"
    end
    
    search_options[:geo] = geo_radians(lat, lon) unless lat.nil? && lon.nil?
    search_options[:conditions] = conditions unless conditions.empty?
    search_options[:with] = with unless with.empty?
    search_options[:page] = options[:page] unless options[:page].nil?
    search_options[:max_matches] = options[:limit] unless options[:limit].nil?

    self.search(options[:query], search_options)
    
  end
  
   #Displays Global results including the url deals
  def self.filtered_url_search(options={})
  # bail early if the provided query is invalid
     puts "filtered_url_search with age:#{options[:age]}"
    return [] if options[:query] and options[:query].blank?

    lat, lon = options[:lat], options[:lon]

    if options[:category] != "url" && options[:category] != nil
      raise NoMethodError, "Coordinates required" if lat.blank? && lon.blank?
    end
     
    range = (options[:range] || 10_000).to_f

    # filtering options
    conditions = {}
    conditions[:category] = options[:category] unless options[:category].nil?
    
    with = {}
    with[:created_at] = options[:age].ago..Time.now unless options[:age].nil?

    search_options = {}

    if options[:category] != "url" && options[:category] != nil
      with["@geodist"] = 0.0..range
      search_options[:order] = "@geodist ASC, @relevance DESC"
    else
      if options[:category] != "url"
        search_options[:order] = "created_at desc"
      end

    end
    
    search_options[:geo] = geo_radians(lat, lon) unless lat.nil? && lon.nil?
    search_options[:conditions] = conditions unless conditions.empty?
    search_options[:with] = with unless with.empty?
    search_options[:page] = options[:page] unless options[:page].nil?
    search_options[:max_matches] = options[:limit] unless options[:limit].nil?

    search_query = "%" + options[:query] + "%"
    puts "SEARCH QUERY:#{search_query}"
    puts "SEARCH OPTIONS#{search_options}"
    self.search(search_query, search_options)  
  end
  
  
  #Deprecated
  # We need to replace the filtered search with this in the future
  def self.filtered_search_3_0(options={})
  # bail early if the provided query is invalid
    return [] if options[:query] and options[:query].blank?

    lat, lon = options[:lat], options[:lon]
    raise NoMethodError, "Coordinates required" if lat.blank? && lon.blank? && options[:category] != "url"
    range = (options[:range] || 10_000).to_f
    # filtering options
    conditions = {}
    conditions[:category] = options[:category] unless options[:category].nil?

    with = {}
    with[:created_at] = options[:age].ago..Time.now unless options[:age].nil?

    search_options = {}

    if options[:category] != "url"
      with["@geodist"] = 0.0..range
      search_options[:order] = "@geodist ASC, @relevance DESC"
    else
      search_options[:order] = "created_at desc"
    end
    
    search_options[:geo] = geo_radians(lat, lon) unless lat.nil? && lon.nil?
    search_options[:conditions] = conditions unless conditions.empty?
    search_options[:with] = with unless with.empty?
    search_options[:page] = options[:page] unless options[:page].nil?
    search_options[:max_matches] = options[:limit] unless options[:limit].nil?
    
    search_query = "%" + options[:query] + "%"
    self.search(search_query, search_options)    
  end
  
  #Deprecated
   def self.filtered_test_search(options={})
  # bail early if the provided query is invalid

    return [] if options[:query] and options[:query].blank?

    lat, lon = options[:lat], options[:lon]

    if options[:category] != "url" && options[:category] != nil
      raise NoMethodError, "Coordinates required" if lat.blank? && lon.blank?
    end
     
    range = (options[:range] || 10_000).to_f

    # filtering options
    conditions = {}
    conditions[:category] = options[:category] unless options[:category].nil?

    with = {}
    with[:created_at] = options[:age].ago..Time.now unless options[:age].nil?

    search_options = {}

    if options[:category] != "url" && options[:category] != nil
      with["@geodist"] = 0.0..range
      search_options[:order] = "@geodist ASC, @relevance DESC"
    else
      if options[:category] != "url"
        search_options[:order] = "created_at desc"
      end

    end
    
    search_options[:geo] = geo_radians(lat, lon) unless lat.nil? && lon.nil?
    search_options[:conditions] = conditions unless conditions.empty?
    search_options[:with] = with unless with.empty?
    search_options[:page] = options[:page] unless options[:page].nil?
    search_options[:max_matches] = options[:limit] unless options[:limit].nil?
    search_query = "%" + options[:query] + "%"
    self.search(search_query, search_options)
    
  end


  def locate_via_foursquare!
    venue = Qwiqq.foursquare_client.venue(foursquare_venue_id) if foursquare_venue_id
    if venue
      if venue["location"]["lat"] != 0.0 && venue["location"]["lng"] != 0.0
        puts "TEST update locationvia4sq"
        update_attributes(
          :lat => venue["location"]["lat"],
          :lon => venue["location"]["lng"],
          :foursquare_venue_name => venue["name"],
          :location_name => venue["location"]["address"])
      end
    end
  end

  def locate_via_coords!
    return unless location_name.blank?
    return if lat == 0.0 && lon == 0.0
    loc = GeoKit::Geocoders::MultiGeocoder.reverse_geocode([ lat, lon ])
    
    if loc.success?
      location_name = loc.city
      location_name = "#{loc.street_name}, #{location_name}" if loc.street_name
      update_attribute(:location_name, location_name)
    end
  end

  # locate using either foursquare, or coords
  def locate!
    if foursquare_venue_id
      locate_via_foursquare!
    else
      locate_via_coords!
    end
  end

  def venue_or_location_name
    foursquare_venue_name || location_name
  end

  def test_email
    puts "EMAIL TESTED"
    user = User.find_by_email("michaelscaria26@gmail.com")
    deal = Deal.find("10345")
    Mailer.category_test(user, deal).deliver
    name
  end
  
  def redeem_coupon!
    transaction do
      if coupon_count > 0
        decrement!(:coupon_count)
        return true
      end
    end if coupon?
    false
  end
  
  def meta_content
    c = self.name.clone
    c << " #shopsmall"
    c << " BUY NOW" if self.for_sale_on_paypal && self.num_left_for_sale > 0
    c << " #{self.price_as_string}" if self.price
    c << " #{Rails.application.routes.url_helpers.deal_url(self, :host => "qwiqq.me")}"
    c
  end
  def async_locate
    Resque.enqueue(LocateDealJob, id)
  end

  private
  def self.geo_radians(lat, lon)
    [ (lat.to_f / 180.0) * Math::PI, 
      (lon.to_f / 180.0) * Math::PI] 
  end
  
  # construct and store hexdigest of important attributes
  # intent is to avoid duplicate posts being created due to server and 
  # network issues
  def store_unique_token!
    input = ""
    input << self.name                        if self.name
    input << self.price.to_s                  if self.price
    input << self.user_id.to_s                if self.user_id
    input << self.category_id.to_s            if self.category_id

    input << self.foursquare_venue_id.to_s    if self.foursquare_venue_id
    input << self.foursquare_venue_name.to_s  if self.foursquare_venue_name

    #added to allow user to intentional post dup
    input << self.lat.to_s                    if self.lat
    input << self.lon.to_s                    if self.lon
    
    self.unique_token = Digest::MD5.hexdigest(input)
  end
  
  def has_price?
    !price.blank?
  end

  def populate_feed(posting_user = nil, repost = false)
    posting_user ||= self.user
    users = [ posting_user, posting_user.followers ].flatten
    Feedlet.import(users.map {|u| 
      Feedlet.new(:user_id => u.id, 
                  :deal_id => self.id, 
                  :posting_user_id => posting_user.id, 
                  :reposted_by => repost ? posting_user.username : nil, 
                  :timestamp => repost ? repost.created_at : self.created_at)})
  end

  def set_user_photo
    self.user_photo = self.user.photo(:iphone_small)
    self.user_photo_2x = self.user.photo(:iphone_small_2x)
  end

  def set_coupon_attributes
    #self.coupon = (self.name =~ /#{COUPON_TAG}/).present?
    #self.coupon_count = DEFAULT_COUPON_COUNT if coupon?
    true
  end
end


