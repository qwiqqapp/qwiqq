class Comment < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :deal, :counter_cache => true, :touch => true
  belongs_to :user, :counter_cache => true, :touch => true

  validates_presence_of :deal, :user, :body

  has_many :events, :class_name => "UserEvent", :dependent => :destroy
  
  default_scope :order => 'created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  
  after_commit :async_deliver_notification, :on => :create
  after_commit :create_event, :on => :create

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
    return unless notification_sent_at.nil?       # avoid double notification
    return unless deal.user.send_notifications    # only send if user has notifications enabled
    
    return unless deal.user.id != self.user.id
    Mailer.deal_commented(deal.user, self).deliver
    update_attribute(:notification_sent_at, Time.now)
  end
  
  def async_deliver_notification
    Resque.enqueue(CommentNotifyJob, self.id)
  end

  def mentioned_users
    body.scan(/@([\w-]+)/).map {|match| User.find_by_username(match[0]) }.compact
  end

  def create_event
    Resque.enqueue(CreateCSVJob, self.id)

    # create a 'comment' event
    events.create(
      :event_type => "comment", 
      :metadata => { :body => body }, 
      :deal => deal,
      :user => deal.user, 
      :created_by => user)
    
    # create a 'mention' event for each mentioned user
    mentioned_users.each do |mentioned_user|
      events.create(
        :event_type => "mention",
        :metadata => { :body => body },
        :deal => deal,
        :user => mentioned_user,
        :created_by => user)
    end
  end
end
