class User < ActiveRecord::Base
  
  has_many :deals
  has_many :comments
  
  has_attached_file :photo, 
                    :styles => {  :admin    => ["50x50#", :jpg],
                                  :iphone   => ["75x75#", :jpg],
                                  :iphone2x => ["150x150#", :jpg]}
  
  
end