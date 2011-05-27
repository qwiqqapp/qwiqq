class Like < ActiveRecord::Base
  
  belongs_to :deal
  belongs_to :user
  
end
