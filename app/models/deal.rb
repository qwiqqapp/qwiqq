class Deal < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  belongs_to :user
  belongs_to :category
  
  has_many :comments
  has_many :likes
  
  #TODO update to 3.1 and use role based attr_accessible for premium
  attr_accessible :name, :category_id, :price, :lat, :lon, :photo, :premium
  
  validates_presence_of :name, :category_id, :lat, :lon

  before_create :geodecode_location_name!
  
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  scope :premium, where(:premium => true)
  scope :search, lambda { |query| where([ 'UPPER(name) like ?', "%#{query.upcase}%" ]) }

  has_attached_file :photo,
                    {:styles => { :admin_sml    => ["30x30#", :jpg],
                                  :admin_med    => ["50x50#", :jpg],
                                  :admin_lrg    => ["240x", :jpg],
                                  :iphone       => ["75x75#", :jpg],
                                  :iphone2x     => ["150x150#", :jpg]}
                    }.merge(PAPERCLIP_STORAGE_OPTIONS)
  
  def self.geodecode_location_name(lat, lon)
    loc = GeoKit::Geocoders::MultiGeocoder.reverse_geocode([ lat, lon ])
    "#{loc.street_name}, #{loc.city}" if loc.success?
  end
                    
  def as_json(options={})
    {
      :deal_id        => id.try(:to_s),
      :name           => name,
      :category       => category.try(:name),
      :photo          => photo.url(:iphone),
      :photo_2x       => photo.url(:iphone2x),
      :premium        => premium,
      :price          => price,
      :lat            => lat.try(:to_s),
      :lon            => lon.try(:to_s),
      :comment_count  => comment_count,
      :like_count     => like_count,
      :age            => (created_at ? time_ago_in_words(created_at) : ""),
      :location_name  => location_name
    }
  end

  private
  def geodecode_location_name!
    self[:location_name] = Deal.geodecode_location_name(lat, lon) if location_name.blank?
  end
end
