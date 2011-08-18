class Like < ActiveRecord::Base
  belongs_to :deal, :counter_cache => true
  belongs_to :user
  after_create { deal.indextank_doc.sync_variables }
  after_destroy { deal.indextank_doc.sync_variables }
  
  validates_presence_of :deal, :user
  
  default_scope :order => 'likes.created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  
  after_create :deliver_notification
  
  private
  def deliver_notification    
    Mailer.deal_liked(deal.user, self).deliver if deal.user.send_notifications
  end
end
