class User < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  define_index do
    indexes first_name
    indexes last_name
    indexes username
    set_property :min_prefix_len => 3
  end
  
  has_many :deals, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :liked_deals, :through => :likes, :source => :deal
  has_many :feedlets, :dependent => :destroy
  has_many :posted_feedlets, :class_name => 'Feedlet', :foreign_key => 'posting_user_id', :dependent => :destroy

  has_many :feed_deals, :through => :feedlets, :source => :deal

  has_many :relationships, :dependent => :destroy
  has_many :inverse_relationships, :dependent => :destroy, :class_name => "Relationship", :foreign_key => "target_id"
    
  has_many :following, :through => :relationships, :source => :target
  has_many :followers, :through => :inverse_relationships, :source => :user
  has_many :friends, :through => :relationships, :source => :target, :conditions => ['friends = ?', true]
  has_many :shares, :dependent => :destroy
  has_many :shared_deals, :through => :shares, :source => :deal, :uniq => true
  
  has_many :invitations_sent, :class_name => "Invitation"
  has_many :apn_devices, :class_name => 'APN::Device'

  has_many :events, :class_name => "UserEvent"
  has_many :events_created, :class_name => "UserEvent", :foreign_key => "created_by_id"
  
  scope :sorted, :order => 'users.username ASC'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  scope :suggested, where(:suggested => true)
    
  attr_accessible :first_name, 
                  :last_name, 
                  :username, 
                  :email,
                  :password, 
                  :password_confirmation,
                  :photo, 
                  :country, 
                  :city, 
                  :facebook_access_token,
                  :twitter_access_token, 
                  :twitter_access_secret,
                  :foursquare_access_token,
                  :send_notifications, 
                  :bio,
                  :push_token,
                  :phone,
                  :website,
                  :suggested,
                  :photo_service

  attr_accessor :push_token
  attr_accessor :password
  attr_accessor :photo_service
  
  before_save :encrypt_password
  before_save :update_twitter_id
  before_save :update_facebook_id
  before_save :update_foursquare_id
  before_save :update_notifications_token
  before_save :update_photo_from_service
  after_save :update_push_token # may be called on create and we need user_id to create an APN::Device
  
  validates_confirmation_of :password
  validates_presence_of     :password, :on => :create
  validates_length_of       :password, :minimum => 5, :allow_nil => true
  validates                 :email, :presence => true, :uniqueness => {:case_sensitive => false}, :email => true
  validates_uniqueness_of   :username, :case_sensitive => false
  validates_format_of       :username, :with => /^[\w\d_]+$/, :message => "use only letters, numbers and '_'"
  
  # see initializers/auto_orient.rb for new processor
  has_attached_file :photo, { 
    :processors => [:auto_orient, :thumbnail],
    :styles => { 
      # api
      :iphone => ["75x75#", :jpg],
      :iphone2x => ["150x150#", :jpg],
                                  
      # user detail view
      :iphone_profile => ["85x85#", :jpg],
      :iphone_profile_2x => ["170x170#", :jpg],                                  
                                  
      # large image for zoom
      :iphone_zoom => ["300x300#", :jpg],
      :iphone_zoom_2x => ["600x600#", :jpg],

      # app v2
      :iphone_small => ["40x40#", :jpg],
      :iphone_small_2x => ["80x80#", :jpg]
    }
  }.merge(PAPERCLIP_STORAGE_OPTIONS)

  strip_attrs :email, :city, :country, :first_name, :last_name, :username, :bio, :phone, :website

  def location
    if !city.blank? && !country.blank?
      "#{city}, #{country}"
    elsif !city.blank? && country.blank?
      "#{city}"
    else
      country
    end
  end
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  def deliver_password_reset!
    update_attribute(:reset_password_token, Qwiqq.friendly_token)
    Mailer.password_reset(self).deliver
    update_attribute(:reset_password_sent_at, Time.now)
  end
  
  # TODO check for token age, should be younger than 24.hours
  def self.validate_password_reset(token)
    self.find_by_reset_password_token(token)
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def name
    "#{first_name} #{last_name}".titleize
  end

  def follow!(target)
    reciprocal = !target.relationships.where(:target_id => self).blank?
    relationships.create(:target => target, :friends => reciprocal)
    rel = target.relationships.where(:target_id => self)
    rel.update_all(:friends => true)
    rel.each do |r|
      r.update_counts
    end

    Feedlet.import( target.deals.map { |d| 
      self.feedlets.new(:posting_user_id => target.id, :deal_id => d.id, :timestamp => d.created_at) } )
  end

  def unfollow!(target)
    self.feedlets.where(:posting_user_id => target.id).delete_all
    relationships.find_by_target_id(target.id).try(:destroy)
    rel = target.relationships.where(:target_id => self)
    rel.update_all(:friends => false)
    rel.each do |r|
      r.update_counts
    end
  end
  
  def following?(target)
    relationships.exists?(:target_id => target.id)
  end
  
  def friends?(target)
    Relationship.find_by_sql(
      "SELECT r1.* FROM relationships r1, relationships r2 
       WHERE r1.user_id = r2.target_id AND r1.target_id = r2.user_id 
         AND r1.user_id = #{id} AND r1.target_id = #{target.id}").any?
  end

  def email_invitation_sent?(email)
    invitations_sent.exists?(:service => "email", :email => email)
  end
  
  def as_json(options={})
    options ||= {}
    options.reverse_merge!(:deals => false, :comments => false)
    json = {
      :user_id               => id.try(:to_s),
      :first_name            => first_name,
      :last_name             => last_name,
      :user_name             => username,
      :city                  => city,
      :bio                   => bio,
      :country               => country,
      :created_at            => created_at,
      :updated_at            => updated_at,
      :join_date             => created_at.to_date.to_s(:long).gsub(/\s+/, " "),
      :send_notifications    => send_notifications,
      :facebook_authorized   => !facebook_access_token.blank?,
      :twitter_authorized    => !twitter_access_token.blank?,
      :foursquare_authorized => !foursquare_access_token.blank?,
      :followers_count       => followers_count,
      :following_count       => following_count,
      :friends_count         => friends_count,
      :phone                 => phone,
      :website               => website,

      # user detail photo
      :photo                 => photo.url(:iphone),
      :photo_2x              => photo.url(:iphone2x),
      
      # user detail photo zoom
      :photo_zoom            => photo.url(:iphone_zoom),
      :photo_zoom_2x         => photo.url(:iphone_zoom_2x),
      
      # profile image on deal detail screen
      :photo_profile         => photo.url(:iphone_profile),
      :photo_profile_2x      => photo.url(:iphone_profile_2x),      

      :photo_small           => photo.url(:iphone_small),
      :photo_small_2x        => photo.url(:iphone_small_2x),
      
      # counts
      :like_count            => likes_count,
      :deal_count            => deals_count,
      :comment_count         => comments_count,
      
      # conditional
      :deals                 => options[:deals]    ? deals.sorted.limit(6) : nil,
      :liked_deals           => options[:deals]    ? liked_deals.sorted.limit(6) : nil,
      :comments              => options[:comments] ? comments.limit(3) : nil,
      :events                => options[:events]   ? events.limit(20) : nil
    }

    # add is_following and is_followed if possible
    if current_user = options[:current_user] 
      if current_user == self
        json[:email] = email
      else
        json[:is_following] = current_user.following?(self)
        json[:is_followed] = self.following?(current_user)
      end
    end

    json
  end

  def facebook_client
    @facebook_client ||= Koala::Facebook::GraphAPI.new(facebook_access_token)
  end

  def twitter_client
    @twitter_client ||= Twitter::Client.new(
      :consumer_key => Qwiqq.twitter_consumer_key, 
      :consumer_secret => Qwiqq.twitter_consumer_secret, 
      :oauth_token => twitter_access_token, 
      :oauth_token_secret => twitter_access_secret)
  end

  def foursquare_client
    @foursquare_client ||= Foursquare.new(:access_token => foursquare_access_token)
  end
  
  def twitter_friend_ids
    twitter_ids = []
    begin
      result = twitter_client.friends(:cursor => (cursor ||= -1))
      cursor = result.next_cursor
      twitter_ids << result.users.map {|f| f["id"].to_s } if result.users
    end while cursor != 0
    twitter_ids.flatten
  end

  def facebook_friend_ids
    facebook_ids = []
    friends = facebook_client.get_connections("me", "friends")
    begin
      facebook_ids = friends.map {|f| f["id"].to_s }
      friends = friends.next_page
    end while friends
    facebook_ids.flatten
  end

  def send_push_notification(message, page = "")
    self.apn_devices.each do |device|
      APN::Notification.create!(
        :device => device, 
        :sound => true, 
        :alert => message, 
        :custom_properties => { :page => page }, 
        :badge => events.unread.count)
    end
  end

  def update_photo_from_facebook
    return if facebook_access_token.blank?
    picture_url = facebook_client.get_picture("me", :type => "large") rescue nil
    self.photo = Paperclip::RemoteFile.new(picture_url) if picture_url
  end

  def update_photo_from_twitter
    return if twitter_access_token.blank?
    profile_image_url = twitter_client.profile_image(:size => :original) rescue nil
    self.photo = Paperclip::RemoteFile.new(profile_image_url) if profile_image_url
  end

  private
    def update_twitter_id
      return unless twitter_access_token_changed?
      unless twitter_access_token.blank?
        twitter_user = twitter_client.user rescue nil
        self.twitter_id = twitter_user.id.to_s if twitter_user
      end
    end

    def update_push_token
      return if push_token.blank?
      APN::Device.where("token = ? AND user_id != ?", push_token, self.id).destroy_all
      APN::Device.create(:token => push_token, :user_id => self.id)
      push_token = nil
    end
  
    def update_facebook_id
      return unless facebook_access_token_changed?
      unless facebook_access_token.blank?
        me = facebook_client.get_object("me") rescue nil
        self.facebook_id = me["id"] if me
      end
    end

    def update_foursquare_id
      return unless foursquare_access_token_changed?
      unless foursquare_access_token.blank?
        user = foursquare_client.user("self")
        self.foursquare_id = user["id"]
      end
    end

    def update_notifications_token
      self.notifications_token ||= Qwiqq.friendly_token
    end

    def update_photo_from_service
      case photo_service
      when "facebook" then update_photo_from_facebook
      when "twitter" then update_photo_from_twitter
      end
    end
end

