class Like < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user
  
  validates_presence_of :deal, :user
  
  default_scope :order => 'likes.created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  
  after_create :deliver_notification
  after_create :increment_like_count
  after_destroy :decrement_like_count
  
  private
  def deliver_notification
    Mailer.deal_liked(self).deliver
  end

  #  TODO offload sync variables to job
  def increment_like_count
    deal.increment!(:like_count)
    deal.indextank_doc.sync_variables
  end

  #  TODO offload sync variables to job   
  def decrement_like_count
    deal.decrement!(:like_count)
    deal.indextank_doc.sync_variables
  end
end
