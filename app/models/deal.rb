class Deal < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  
  MAX_AGE = 35
  MAX_RANGE = 40234   # default search range in metres (25 miles)
  COUPON_TAG = "#coupon"
  DEFAULT_COUPON_COUNT = 100
  
  define_index do
    indexes :name
    indexes :foursquare_venue_name
    indexes category(:name), :as => :category
    
    has "RADIANS(lat)", :as => :lat_radians, :type => :float
    has "RADIANS(lon)", :as => :lon_radians, :type => :float
    
    set_property :latitude_attr => :lat_radians, :longitude_attr => :lon_radians

    has created_at, likes_count, comments_count, lat, lon
  end

  belongs_to :user, :counter_cache => true, :touch => true
  belongs_to :category
  
  has_many :comments, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :shares
  has_many :liked_by_users, :through => :likes, :source => :user
  has_many :feedlets, :dependent => :destroy
  has_many :events, :class_name => "UserEvent", 
    :conditions => [ "event_type IN (?)", [ "comment", "like", "share" ] ], 
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
                  :coupon_count
  
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
  
  scope :today, lambda { where("DATE(created_at) = ?", Date.today) }
  scope :recent, lambda { where("DATE(created_at) > ?", 30.days.ago) }
  scope :premium, where(:premium => true)
  scope :sorted, :order => "created_at desc"
  scope :popular, order("likes_count desc, comments_count desc")
  scope :coupon, where(:coupon => true)
  
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
      
      :comment_count  => comments_count,
      :like_count     => likes_count,
      :age            => age_in_words.gsub("about ", ""),
      :short_age      => short_age_in_words,
      :location_name  => location_name,
      :venue_name     => foursquare_venue_name,
      :user_id        => user_id.try(:to_s),
      :repost_count   => reposts_count,
      :share_count    => shares_count,
      
      :number_users_shared    => number_users_shared,
    }

    # add 'liked' for the current user if requested
    current_user = options[:current_user]
    json[:liked] = current_user.liked_deals.include?(self) if current_user

    # add detail if requested
    unless options[:minimal]
      json[:category]       = category.try(:name)
      json[:events]         = events.limit(60)
      json[:comments]       = comments.limit(3)
      json[:liked_by_users] = liked_by_users.limit(6)
      json[:user]           = user.try(:as_json)
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
  
  def price_as_string
    if self.price > 0
      number_to_currency(price.to_f / 100)
    else
      "Free"
    end
  end
  
  def age_in_words
    created_at ? time_ago_in_words(created_at) : ""
  end

  def short_age_in_words
    created_at ? short_time_ago_in_words(created_at) : ""
  end
  
  # construct message base string, example: The best bubble tea ever! $5.99 @ Happy Teahouse http://qwiqq.me/posts/2259  
  def share_message
    meta = price_as_string || ""
    meta << " @ #{foursquare_venue_name}" if foursquare_venue_name
    meta << " #{Rails.application.routes.url_helpers.deal_url(self, :host => "qwiqq.me")}"
    
    "#{name.truncate(138 - meta.size)} #{meta}"
  end
  
  def number_users_shared_method
    #user_ids = user_ids.uniq
    average = "0"
    if shares_count == 1
      average = "1"
    end
    if shares_count > 4 
      user_ids = []
      if events
        user_ids << events.map do |event|
            if event.event_type == "share"
              event.created_by_id.hash
            end
        end
      end
      user_ids = user_ids[0].uniq
      user_ids = user_ids.compact
      average = "#{user_ids.count}"
   end
   average
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

    self.search(options[:query], search_options)
    
  end
  
  #Displays Global results including the url deals
  def self.filtered_url_search(options={})
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

    self.search(options[:query], search_options)
    
  end


  def locate_via_foursquare!
    venue = Qwiqq.foursquare_client.venue(foursquare_venue_id) if foursquare_venue_id
    if venue
      if venue["location"]["lat"] != 0.0 && venue["location"]["lng"] != 0.0
        update_attributes(
          :lat => venue["location"]["lat"],
          :lon => venue["location"]["lng"],
          :foursquare_venue_name => venue["name"],
          :location_name => venue["location"]["address"])
      end
    end
    
  end

  def locate_via_foursquare!
    venue = Qwiqq.foursquare_client.venue(foursquare_venue_id) if foursquare_venue_id
    if venue
      if venue["location"]["lat"] != 0.0 && venue["location"]["lng"] != 0.0
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
  
  def love_name
    c = "Loved your "
    c << "#{self.name}"
    c << " post."
    c
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
    c = ""
    c << "An Awesome Qwiqq #coupon! " if self.coupon?
    c << self.price_as_string if self.price
    c << " at #{venue_or_location_name}." unless venue_or_location_name.blank?
    c << " Posted by @#{self.user.username}"
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
    self.coupon = (self.name =~ /#{COUPON_TAG}/).present?
    self.coupon_count = DEFAULT_COUPON_COUNT if coupon?
    true
  end
end


