class UserEvent < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  belongs_to :deal
  belongs_to :comment

  serialize :metadata

  before_save :update_cached_attributes
  
  after_create :deliver_push_notification
  
  validates :event_type, :inclusion => [ "comment", "like", "share", "follower", "mention" ]
  validates :user, :presence => true
  validates :created_by, :presence => true
  
  scope :read, where(:read => true)
  scope :unread, where(:read => false) do
    def clear
      unread.update_all(:read => true)
    end
  end
  
  default_scope :order => "created_at DESC"
  
  def as_json(options={})
    json = { 
      :type => event_type,
      :created_by_id => created_by_id,
      :created_by_username => created_by_username,
      :created_by_photo => created_by_photo,
      :created_by_photo_2x => created_by_photo_2x,
      :short_age => short_time_ago_in_words(created_at)
    }
    
    if deal
      json[:deal_name] = deal_name
      json[:deal_id] = deal_id
    end
    
    case event_type
    when "comment" || "mention"
      json[:body] = metadata[:body]
    when "share"
      json[:service] = metadata[:service]
    end
    
    json
  end
  
  # TODO move to separate notification class
  def deliver_push_notification
    return unless push_notification_sent_at.nil?
    
    device_tokens = self.user.push_devices.map(&:token)
    return false if device_tokens.blank?
    
    badge = self.user.events.unread.count
    
    notification = {
      :device_tokens => device_tokens,
      :aps => { :alert  => push_alert, 
                :badge  => badge}
    }
    
    update_attribute(:push_notification_sent_at, Time.now) if Urbanairship.push(notification)
  end

  private
  def push_link
    #return page hash
    case self.event_type
      when /follower/i
        "users/#{self.user_id}"
      else
        "deals/#{self.deal_id}"
      end
  end
  
  def push_alert
    action = case self.event_type
      when 'comment'
        "left a comment on your post: #{metadata[:body]}"
      when 'like'
        "loved your post"
      when 'share'        
        "shared your post on #{metadata[:service]}"
      when 'follower'
        "started following you"
      when 'mention'  
        "mentioned you in a comment: #{metadata[:body]}"
      else
        raise ArgumentError, "Unable to create notification message for event #{self.id} with type #{self.event_type}"
      end 
    "#{self.user.username} #{action}"
  end
  
  
  def update_cached_attributes
    self.created_by_photo = created_by.photo(:iphone_small)
    self.created_by_photo_2x = created_by.photo(:iphone_small_2x)
    self.created_by_username = created_by.username
    self.deal_name = deal.name if deal
  end
end

