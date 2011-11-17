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

  has_many :events, :class_name => "UserEvent"
  
  #TODO update to 3.1 and use role based attr_accessible for premium
  attr_accessible :name, :category_id, :price, :lat, :lon, :photo, :premium, :percent, :location_name,
    :foursquare_venue_id, :foursquare_venue_name, :foursquare_venue_lat, :foursquare_venue_lon
  
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

  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  scope :premium, where(:premium => true)
  scope :sorted, :order => "created_at desc"
  
  def populate_feed(posting_user = nil, repost = false)
    posting_user ||= self.user
    Feedlet.import(posting_user.followers.map {|f| 
      Feedlet.new(:user_id => f.id, 
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
      :category       => options[:minimal] ? nil : category.try(:name),
      
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
      :age            => age.gsub("about ", ""),
      :short_age      => short_created_at,
      :location_name  => location_name,
      :venue_name     => foursquare_venue_name,
      :user           => options[:minimal] ? nil : user.try(:as_json, :deals => false),
      :repost_count   => reposts_count,
      :share_count    => shares_count
    }

    return json if options[:minimal]
    
    # add 'liked' for the current_user if requested
    current_user = options[:current_user]
    if current_user
      json[:liked] = current_user.liked_deals.include?(self)
    end
    
    # add comments and users who liked this deal if requested 
    json[:comments] = comments.limit(3) if options[:comments]
    json[:liked_by_users] = liked_by_users.limit(6) if options[:liked_by_users]
    
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
  
  def age
    created_at ? time_ago_in_words(created_at) : ""
  end
  

  def short_created_at
    from_time = created_at
    to_time = Time.now
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
    when 0..1
      "#{distance_in_seconds}s"
    when 2..44           then "#{distance_in_minutes}m"
    when 45..1439        then "#{(distance_in_minutes.to_f / 60.0).round}hr"
    when 1440..43199     then "#{(distance_in_minutes.to_f / 1440.0).round}d"
    when 43200..525599   then "#{(distance_in_minutes.to_f / 43200.0).round}mo"
    else
      "#{distance_in_minutes / 525600}y"
    end
  end
  
  # TODO merge this with filtered_search
  def self.category_search(name, lat, lon, opts = {})
    # required
    opts.merge!({:conditions => {:category => name}})
    opts[:order]  = "@relevance DESC"
    opts.delete(:page) if opts[:page].nil?
    
    # optional
    if lat && lon
      opts[:geo]    = geo_radians(lat, lon)
      opts[:order]  = "@geodist ASC, @relevance DESC"
      #opts[:with]   = {"@geodist" => 0.0..10_000.0}
    end
    
    self.search(opts)
  end
  
  def self.filtered_search(query, filter, lat=nil, lon=nil, opts = {})
    return [] if query.blank?
    
    opts.merge!({:conditions => {:name => query}})
    opts.delete(:page) if opts[:page].nil?
    
    case filter
      when 'newest'
        opts[:order]      = "created_at DESC, @relevance DESC"
        
      when 'nearby'
        raise NoMethodError, 'Coordinates required' if lat.blank? && lon.blank?
        
        opts[:order]      = "@geodist ASC, @relevance DESC"
        opts[:geo]        = geo_radians(lat, lon)
        #opts[:with]       = {"@geodist" => 0.0..10_000.0}
        
      when 'popular'
        opts[:sort_mode]  = :expr
        opts[:order]      = "@weight * likes_count * comments_count" 
      
      else
        raise NoMethodError, 'Search filter not valid'  
    end
    
    # compact to remove stale deals returned by TS
    # TS has retry option but it's time expensive
    self.search(opts)
  end

  def self.nearby(lat, lon)
    self.search(:order => "@geodist ASC, created_at DESC",
                :geo => geo_radians(lat, lon),
                :max_matches => 15).compact
  end
  
  def locate_via_foursquare!
    venue = Qwiqq.foursquare_client.venue(foursquare_venue_id) if foursquare_venue_id
    if venue
      update_attributes(
        :foursquare_venue_lat => venue["location"]["lat"],
        :foursquare_venue_lon => venue["location"]["lng"],
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

  def locate!
    # locate using either foursquare, or coords
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
    input << self.name              if self.price
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

