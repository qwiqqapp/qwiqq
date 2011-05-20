class Deal < ActiveRecord::Base
  belongs_to :user
  belongs_to :location
  belongs_to :category
  
  has_many :comments
  
  validates_presence_of :name, :category_id, :price, :location_id
  
  scope :today, lambda{ where('DATE(created_at) = ?', Date.today)}
  
  
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
        :price      => price,
        :location   => location.try(:name),
        :address    => location.try(:address),
        :lat        => location.try(:lat).try(:to_s),
        :lon       => location.try(:lon).try(:to_s)
      }
    end


end
