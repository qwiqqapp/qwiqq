class Comment < ActiveRecord::Base
  
  belongs_to :deal
  belongs_to :user

  validates_presence_of :body, :deal, :user
  
  default_scope :order => 'created_at desc'

end
