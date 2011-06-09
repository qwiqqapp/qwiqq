class Deal < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  belongs_to :user
  belongs_to :category
  
  has_many :comments
  has_many :likes

  has_many :liked_by_users, :through => :likes, :source => :user
  
  #TODO update to 3.1 and use role based attr_accessible for premium
  attr_accessible :name, :category_id, :price, :lat, :lon, :photo, :premium, :percent
  
  validates_presence_of :user, :category, :name, :lat, :lon, :message => "is required"
  
  validates_length_of   :name, :maximum => 70, :message=> "max characters is 70"
  
  validate :has_price_or_percentage
  
  before_create :geodecode_location_name!
  
  default_scope :order => 'deals.created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  scope :premium, where(:premium => true)
  scope :search_by_name, lambda { |query| where([ 'UPPER(name) like ?', "%#{query.upcase}%" ]) }

  has_attached_file :photo,
                    {:styles => { #admin
                                  :admin_sml    => ["30x30#", :jpg],
                                  :admin_med    => ["50x50#", :jpg],
                                  :admin_lrg    => ["240x", :jpg],
                                  
                                  # popular
                                  :iphone_grid       => ["75x75#", :jpg],
                                  :iphone_grid_2x    => ["150x150#", :jpg],
                                  
                                  # feed, browse, search list views
                                  :iphone_list       => ["55x55#", :jpg],
                                  :iphone_list_2x    => ["110x110#", :jpg],
                                  
                                  # zoomed image size
                                  :iphone_zoom       => ["300x440>", :jpg],
                                  :iphone_zoom_2x    => ["600x880>", :jpg]
                                  }
                    }.merge(PAPERCLIP_STORAGE_OPTIONS)
  
  def self.geodecode_location_name(lat, lon)
    loc = GeoKit::Geocoders::MultiGeocoder.reverse_geocode([ lat, lon ])
    "#{loc.street_name}, #{loc.city}" if loc.success?
  end
                    
  def as_json(options={})
    options ||= {}

    json = {
      :deal_id        => id.try(:to_s),
      :name           => name,
      :category       => category.try(:name),
      
      # popular
      :photo_grid     => photo.url(:iphone_grid),
      :photo_grid_2x  => photo.url(:iphone_grid_2x),
      
      # feed, browse and search
      :photo_list     => photo.url(:iphone_list),
      :photo_list_2x  => photo.url(:iphone_list_2x),
      
      # deal detail zoom
      :photo_zoom     => photo.url(:iphone_zoom),
      :photo_zoom_2x  => photo.url(:iphone_zoom_2x),            
      
      :premium        => premium,
      :price          => price,
      :percent        => percent,
      :lat            => lat.try(:to_s),
      :lon            => lon.try(:to_s),
      :comment_count  => comment_count,
      :like_count     => like_count,
      :age            => (created_at ? time_ago_in_words(created_at).gsub("about ", "") : ""),
      :short_age      => short_created_at,
      :location_name  => location_name,
      :user           => user.try(:as_json, :deals => false)
    }

    # add 'liked' for the current_user if requested
    current_user = options[:current_user]
    if current_user
      json[:liked] = current_user.liked_deals.include?(self)
    end

    # add comments and users who liked this deal if requested 
    json[:comments] = comments if options[:comments]
    json[:liked_by_users] = liked_by_users if options[:liked_by_users]

    json
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

  private
  def geodecode_location_name!
    self[:location_name] = Deal.geodecode_location_name(lat, lon) if location_name.blank?
  end

  def has_price_or_percentage
    errors.add_to_base("You must specify a price or percentage") if price.blank? && percent.blank?
  end
end

