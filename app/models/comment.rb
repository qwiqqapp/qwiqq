class Comment < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :deal, :counter_cache => true
  belongs_to :user

  validates_presence_of :deal, :user, :body
  
  default_scope :order => 'created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}

  after_create :deliver_notification

  strip_attrs :body

  # TODO replace with use of super(options) to allow for controller to override defaults
  def as_json(options={})
    {
      :comment_id   => id.try(:to_s),
      :body         => body,
      :age          => age.gsub("about ", ""),
      :user         => { :user_id   => user.id.try(:to_s),
                         :name      => user.name,
                         :user_name => user.username,
                         :photo     => user.photo.url(:iphone),
                         :photo_2x  => user.photo.url(:iphone2x)},
      :deal         => { :deal_id => deal.id.try(:to_s),
                         :name    => deal.name,
                         :photo_grid     => deal.photo.url(:iphone_grid),
                         :photo_grid_2x  => deal.photo.url(:iphone_grid_2x)}
      
    }
  end
  
  
  def age
    created_at ? time_ago_in_words(created_at) : ""
  end
  
  def deliver_notification
    Mailer.deal_commented(deal.user, self).deliver if deal.user.send_notifications
  end
end
