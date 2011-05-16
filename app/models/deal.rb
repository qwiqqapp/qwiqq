class Deal < ActiveRecord::Base
  belongs_to :user
  belongs_to :location
  belongs_to :category
  
  has_many :comments
  
  scope :today, lambda{ where('DATE(created_at) = ?', Date.today)}
  
  
  has_attached_file :photo, 
                    {:styles => { :admin    => ["50x50#", :jpg],
                                  :iphone   => ["75x75#", :jpg],
                                  :iphone2x => ["150x150#", :jpg]}
                    }.merge(PAPERCLIP_STORAGE_OPTIONS)
  

    def as_json(options={})
      {
        :id         => id,
        :name       => name,
        :category   => category.try(:name),
        :location   => location.try(:address),
        :photo      => photo.url(:iphone),
        :photo_2x   => photo.url(:iphone2x)
      }
    end


end
