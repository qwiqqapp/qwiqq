class Deal < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  
  define_index do
    indexes :name
    indexes :foursquare_venue_name
    indexes category(:name), :as => :category
    
    has "RADIANS(lat)", :as => :lat_radians,  :type => :float
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
                  :percent, 
                  :location_name,
                  :foursquare_venue_id, 
                  :foursquare_venue_name
  
  # TODO update to 3.0 validates method
  validates_presence_of   :user, :category, :name, :message => "is required"
  validates_length_of     :name, :maximum => 70, :message=> "max characters is 70"

  validates_uniqueness_of :unique_token
  
  validate :has_price_or_percentage
  
  validates :percent, :numericality => true, :inclusion => { :in => 0..100 }, :if => :has_percentage?
  validates :price, :numericality => true, :if => :has_price?
  
  before_validation :store_unique_token!, :on => :create

  before_create :set_user_photo
  after_create :populate_feed
  after_create :async_locate

  scope :today, lambda { where("DATE(created_at) = ?", Date.today) }
  scope :recent, lambda { where("DATE(created_at) > ?", 30.days.ago) }
  scope :premium, where(:premium => true)
  scope :sorted, :order => "created_at desc"
  
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

  # all images are cropped
  # see initializers/auto_orient.rb for new processor
  #  TODO review all image sizes, need to reduce/reuse
  has_attached_file :photo, { 
    :processors => [:auto_orient, :thumbnail], 
    :styles => { 
      # popular
      :iphone_grid => ["75x75#", :jpg],
      :iphone_grid_2x => ["150x150#", :jpg],
     
      # deal detail view
      :iphone_profile => ["85x85#", :jpg],
      :iphone_profile_2x => ["170x170#", :jpg],

      
      # feed, browse, search list views
      :iphone_list => ["55x55#", :jpg],
      :iphone_list_2x => ["110x110#", :jpg],
     
      # zoomed image size
      :iphone_zoom => ["300x300#", :jpg],
      :iphone_zoom_2x => ["600x600#", :jpg] ,

      # app v2
      :iphone_explore => ['95x95#', :jpg],
      :iphone_explore_2x => ['190x190#', :jpg]
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
      :percent        => percent,
      
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
    }

    # add 'liked' for the current user if requested
    current_user = options[:current_user]
    json[:liked] = current_user.liked_deals.include?(self) if current_user

    # add detail if requested
    unless options[:minimal]
      json[:category]       = category.try(:name)
      json[:events]         = events.limit(20)
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
    number_to_currency price.to_f / 100
  end
  
  def age_in_words
    created_at ? time_ago_in_words(created_at) : ""
  end

  def short_age_in_words
    created_at ? short_time_ago_in_words(created_at) : ""
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
    raise NoMethodError, "Coordinates required" if lat.blank? && lon.blank?
    range = (options[:range] || 10_000).to_f

    # filtering options
    conditions = {}
    conditions[:category] = options[:category] unless options[:category].nil?

    with = {}
    with["@geodist"] = 0.0..range
    with[:created_at] = options[:age].ago..Time.now unless options[:age].nil?

    search_options = {}
    search_options[:order] = "@geodist ASC, @relevance DESC"
    search_options[:geo] = geo_radians(lat, lon)
    search_options[:conditions] = conditions unless conditions.empty?
    search_options[:with] = with unless with.empty?
    search_options[:page] = options[:page] unless options[:page].nil?
    search_options[:max_matches] = options[:limit] unless options[:limit].nil?

    self.search(options[:query], search_options)
  end

  def locate_via_foursquare!
    venue = Qwiqq.foursquare_client.venue(foursquare_venue_id) if foursquare_venue_id
    if venue
      update_attributes(
        :lat => venue["location"]["lat"],
        :lon => venue["location"]["lng"],
        :foursquare_venue_name => venue["name"],
        :location_name => venue["location"]["address"])
    end
  end

  def locate_via_coords!
    return unless location_name.blank?
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

  def async_locate
    Resque.enqueue(LocateDealJob, id)
  end

  private
  def self.geo_radians(lat, lon)
    [ (lat.to_f / 180.0) * Math::PI, 
      (lon.to_f / 180.0) * Math::PI] 
  end
  
  def store_unique_token!
    input = ""
    input << self.name              if self.name
    input << self.price.to_s        if self.price
    input << self.percent.to_s      if self.percent  
    input << self.user_id.to_s      if self.user_id
    input << self.category_id.to_s  if self.category_id
    
    self.unique_token = Digest::MD5.hexdigest(input)
  end
  
  def has_percentage?
    !percent.blank?
  end
  
  def has_price?
    !price.blank?
  end
  
  def has_price_or_percentage
    errors.add(:base, "Price or percent required") if price.blank? && percent.blank?
  end  
end

