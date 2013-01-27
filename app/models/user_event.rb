class UserEvent < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  belongs_to :deal
  belongs_to :comment

  serialize :metadata

  before_save :update_cached_attributes
  
  after_create :deliver_push_notification
  
  validates :event_type, :inclusion => [ "comment", "like", "share", "follower", "mention", "push" ]
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
    when "push"
      json[:facebook_name] = metadata[:body]
    end
    
    json
  end
  
  # TODO move to separate notification class
  def deliver_push_notification
    return unless push_notification_sent_at.nil?      # avoid double send
    return if self.user == self.created_by            # dont deliver if user liked own post
    return if event_type == "push"
    device_tokens = self.user.push_devices.map(&:token)
    return if device_tokens.blank?
    
    badge         = self.user.events.unread.count
    notification  = { :device_tokens => device_tokens,
                      :page => push_page,
                      :aps => { :alert  => push_alert, 
                                :badge  => badge}}
    
    update_attribute(:push_notification_sent_at, Time.now) if Urbanairship.push(notification)
  end
 
  def update_cached_attributes
    self.created_by_photo = created_by.photo(:iphone_small)
    self.created_by_photo_2x = created_by.photo(:iphone_small_2x)
    self.created_by_username = created_by.username
    self.deal_name = deal.name if deal
  end
  
  def mentioned_users
    body = metadata[:body].scan(/@([\w-]+)/)
    puts "mention users body:'#{body}'"
    unless body.empty?
      names = []
      names << body.map do |match| 
        match[0]
      #User.find_by_username(match[0])
      end
      comment_body = metadata[:body]
      names[0].each { |username|
        user = User.find_by_username(username)
        puts "FULL:<a href='http://www.qwiqq.me/users/#{user.id}'>@#{username}</a>"
        link = "<a href='http://www.qwiqq.me/users/#{user.id}'>@#{username}</a>"
        comment_body["@#{username}"] = link
      }
      comment_body
    else
      metadata[:body]
    end
    #names
  end

  private
  def push_page
    case self.event_type
      when /follower/i
        "users/#{created_by_id}"
      when /comment|like|share|mention/
        "deals/#{deal_id}"
      else
        ""
      end
  end
  
  def push_alert
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
  end
end

