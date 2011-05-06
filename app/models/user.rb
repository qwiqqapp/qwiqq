class User < ActiveRecord::Base
  
  has_many :deals
  has_many :comments
  
end