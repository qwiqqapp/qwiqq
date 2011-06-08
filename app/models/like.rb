class Like < ActiveRecord::Base
  
  belongs_to :deal
  belongs_to :user

  default_scope :order => 'created_at DESC'

end
