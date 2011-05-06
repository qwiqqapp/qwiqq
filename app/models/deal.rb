class Deal < ActiveRecord::Base
  belongs_to :user
  belongs_to :location
  belongs_to :category
  
  has_many :comments
  
  has_attached_file :photo, 
                    {:styles => { :admin    => ["50x50#", :jpg],
                                  :iphone   => ["75x75#", :jpg],
                                  :iphone2x => ["150x150#", :jpg]}
                    }.merge(PAPERCLIP_STORAGE_OPTIONS)
  



    def as_json(options={})
      {
        :id         => id,
        :name       => name,
        :category   => category.name,
        :location   => location.address,
        :photo      => photo.url(:iphone),
        :photo_2x   => photo.url(:iphone2x)
      }
    end


end
