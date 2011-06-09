class Deal < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  belongs_to :user
  belongs_to :category
  
  has_many :comments
  has_many :likes
  
  #TODO update to 3.1 and use role based attr_accessible for premium
  attr_accessible :name, :category_id, :price, :lat, :lon, :photo, :premium
  
  validates_presence_of :name, :category_id
  
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  scope :premium, where(:premium => true)
  scope :search, lambda { |query| where([ 'UPPER(name) like ?', "%#{query.upcase}%" ]) }
  
  has_attached_file :photo,
                    {:styles => { :admin_sml    => ["30x30#", :jpg],
                                  :admin_med    => ["50x50#", :jpg],
                                  :admin_lrg    => ["240x", :jpg],
                                  
                                  # popular
                                  :iphone_grid       => ["75x75#", :jpg],
                                  :iphone_grid2x     => ["150x150#", :jpg],
                                  
                                  # feed, browse, search list views
                                  :iphone_list       => ["110x110#", :jpg],
                                  :iphone_list2x     => ["220x220#", :jpg]}
                                  
                    }.merge(PAPERCLIP_STORAGE_OPTIONS)
                    
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
      :age            => (created_at ? time_ago_in_words(created_at) : "")
    }
  end
end
