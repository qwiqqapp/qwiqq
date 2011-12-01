class Category < ActiveRecord::Base
  
  has_many :deals
  validates :name, :uniqueness => true, :presence => true
  
  
end
