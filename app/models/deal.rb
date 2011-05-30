class Deal < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  belongs_to :user
  belongs_to :category
  
  has_many :comments
  has_many :likes
  
  attr_accessible :name, :category_id, :price, :lat, :long, :photo
  
  validates_presence_of :name, :category_id, :price
  
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  scope :premium, where(:premium => true)
  
  has_attached_file :photo, 
                    {:styles => { :admin_sml    => ["30x30#", :jpg],
                                  :admin_med    => ["50x50#", :jpg],
                                  :admin_lrg    => ["240x", :jpg],
                                  :iphone       => ["75x75#", :jpg],
                                  :iphone2x     => ["150x150#", :jpg]}
                    }.merge(PAPERCLIP_STORAGE_OPTIONS)
  

    def as_json(options={})
      {
        :deal_id    => id.try(:to_s),
        :name       => name,
        :category   => category.try(:name),
        :photo      => photo.url(:iphone),
        :photo_2x   => photo.url(:iphone2x),
        :premium    => premium,
        :price      => price,
        :lat        => lat.try(:to_s),
        :lon        => long.try(:to_s),
        :comment_count => comment_count,
        :like_count => like_count,
        :age        => (created_at ? time_ago_in_words(created_at) : "")
      }
    end
end
