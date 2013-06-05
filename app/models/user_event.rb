class UserEvent < ActiveRecord::Base
  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  belongs_to :deal
  belongs_to :comment

  serialize :metadata

  before_save :update_cached_attributes
  
  after_create :deliver_push_notification
  
  validates :event_type, :inclusion => [ "comment", "like", "share", "follower", "mention", "push", "purchase", "sold"]
  validates :user, :presence => true, :unless => :is_on_web?
  validates :created_by, :presence => true, :unless => :is_on_web?
  
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
      :short_age => short_time_ago_in_words(created_at),
      :is_web_event => is_web_event
    }
    
    if !created_by.nil? && !created_by.blank?
      json[:created_by_id] = created_by_id
      json[:created_by_username] = created_by_username
      json[:created_by_photo] = created_by_photo
      json[:created_by_photo_2x] = created_by_photo_2x
    end

    
    if deal
      json[:deal_name] = deal_name
      json[:deal_id] = deal_id
    end
    
    case event_type
    when "comment" || "mention"
      json[:body] = metadata[:body]
    when "share"
      json[:service] = metadata[:service]
    when "push"
      json[:facebook_name] = metadata[:body]
    end
    
    json
  end
  
  def is_on_web?
    self.is_web_event
  end
  
  # TODO move to separate notification class
  def deliver_push_notification
    return unless push_notification_sent_at.nil?      # avoid double send
    return if self.user == self.created_by            # dont deliver if user liked own post
    return if event_type == "push" || event_type == "purchase"
    device_tokens = self.user.push_devices.map(&:token)
    return if device_tokens.blank?
    puts 'CREATING PUSH'
    badge         = self.user.events.unread.count
    notification  = { :device_tokens => device_tokens,
                      :page => push_page,
                      :aps => { :alert  => push_alert, 
                                :badge  => badge}}
    
    update_attribute(:push_notification_sent_at, Time.now) if Urbanairship.push(notification)
  end
 
  def update_cached_attributes
    if created_by
      self.created_by_photo = created_by.photo(:iphone_small)
      self.created_by_photo_2x = created_by.photo(:iphone_small_2x)
      self.created_by_username = created_by.username
    end
    self.deal_name = deal.name if deal
  end
  
  def mentioned_users
    body = metadata[:body].scan(/@([\w-]+)/)
    if body.empty?
      false
    else
      true
    end
  end
  
  def mentioned_users_body
    body = metadata[:body].scan(/@([\w-]+)/)
    names = []
    names << body.map do |match| 
      match[0]
    end
    comment_body = metadata[:body]
    names[0].each { |username|
      user = User.find(:first, :conditions => [ "lower(username) = ?", username.downcase ])
      if !user.nil?
        link = "<a href='http://www.qwiqq.me/users/#{user.id}'>@#{username}</a>"
        comment_body["@#{username}"] = link
      end
    }
    created_link = self.created_by.username
    created_user = User.find(:first, :conditions => [ "lower(username) = ?", self.created_by.username.downcase ])
      if !created_user.nil?
        created_link = "<a href='http://www.qwiqq.me/users/#{created_user.id}'>@#{created_user.username}</a>"
      end
    comment_body = "#{created_link} said #{comment_body}"
    puts "FINAL COMMENT_BODY:#{comment_body}"
    comment_body
  end

  private
  def push_page
    case self.event_type
      when /follower/i
        "users/#{created_by_id}"
      when /comment|like|share|mention|sold/
        "deals/#{deal_id}"
      else
        ""
      end
  end
  
  def push_alert
    unless event_type == "sold"
      action = case event_type
        when "comment"
          "left a comment on your post: #{metadata[:body]}"
        when "like"
          "loved your post"
        when "share"
          "shared your post on #{metadata[:service]}"
        when "follower"
          "started following you"
        when "mention"
          "mentioned you in a comment: #{metadata[:body]}"
        else
          raise ArgumentError, "Unable to create notification message for event #{id} with type #{event_type}"
        end 
      "#{created_by.best_name} #{action}"
    else 
      #sold alert
      "Yeah! I just sold #{deal_name}"
    end
  end
end