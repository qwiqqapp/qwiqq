class FacebookInvalidTokenException < Exception; end

class User < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  serialize :socialyzer_times, Hash
  
  define_index do
    indexes first_name
    indexes last_name
    indexes username
    set_property :min_prefix_len => 3
  end
  
  # new custom push notifications
  has_many :push_devices, :dependent => :destroy
  
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
  has_many :shares, :dependent => :destroy
  has_many :shared_deals, :through => :shares, :source => :deal, :uniq => true
  
  has_many :invitations_sent, :class_name => "Invitation"

  has_many :events, :class_name => "UserEvent"
  has_many :events_created, :class_name => "UserEvent", :foreign_key => "created_by_id"
  
  scope :sorted, :order => 'users.username ASC'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  scope :suggested, where(:suggested => true)
  
  scope :connected_to_facebook, where('facebook_access_token is NOT NULL')
  scope :connected_to_twitter, where('twitter_access_token is NOT NULL')
  scope :connected_to_foursquare, where('foursquare_access_token is NOT NULL')
  scope :socialyzer_enabled, where('socialyzer_enabled_at IS NOT NULL')
  scope :socialyzer_ready, where('socialyzer_times IS NOT NULL')

    
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
                  :facebook_id,
                  :current_facebook_page_id,
                  :twitter_access_token, 
                  :twitter_access_secret,
                  :foursquare_access_token,
                  :send_notifications, 
                  :bio,
                  :push_token,
                  :phone,
                  :website,
                  :suggested,
                  :photo_service,
                  :sent_facebook_push,
                  :paypal_email,
                  :socialyzer_times,
                  :socialyzer_enabled_at,
                  :deals_num

  attr_accessor :push_token
  attr_accessor :password
  attr_accessor :photo_service
  
  before_save :encrypt_password
  before_save :update_notifications_token
  before_save :update_photo_from_service
  
  # update social id when access_token is updated
  before_save :update_twitter_id
  before_save :update_facebook_id
  before_save :update_foursquare_id
  
  # may be called on create and we need user_id to create a push_device
  after_save :update_push_token 
  
  # create worker to update cached user event attributes
  # Todo fix, currently not working

  # after_save :async_update_cached_user_attributes
  
  validates_confirmation_of :password
  validates_presence_of     :password, :on => :create
  validates_length_of       :password, :minimum => 5, :allow_nil => true
  validates                 :email, :presence => true, :uniqueness => {:case_sensitive => false}, :email => true
  validates_uniqueness_of   :username, :case_sensitive => false
  validates_format_of       :username, :with => /^[\w\d_]+$/, :message => "must only contain letters, numbers and underscores."
  
  # see initializers/auto_orient.rb for new processor
  # see initializers/paperclip.rb for default image (missing) location
  has_attached_file :photo, { 
    :processors => [:auto_orient, :thumbnail],
    :styles => { 
      # api
      :iphone => ["75x75#", :jpg],
      :iphone2x => ["150x150#", :jpg],
                                  
      # user detail view
      :iphone_profile => ["95x95#", :jpg],
      :iphone_profile_2x => ["190x190#", :jpg],
                                  
      # large image for zoom
      :iphone_zoom => ["300x300#", :jpg],
      :iphone_zoom_2x => ["600x600#", :jpg],

      # app v2
      :iphone_small => ["40x40#", :jpg],
      :iphone_small_2x => ["80x80#", :jpg]
    }
  }.merge(PAPERCLIP_STORAGE_OPTIONS)

  strip_attrs :email, :city, :country, :first_name, :last_name, :username, :bio, :phone, :website

  def num_for_sale_on_paypal
    #SELECT COUNT(*) FROM deals WHERE deals.user_id = 13527 AND hidden=FALSE;
    return Deal.where('user_id=? AND for_sale_on_paypal=TRUE AND hidden=FALSE',self.id).count
  end
  
  def count_posts
    #SELECT COUNT(*) FROM deals WHERE deals.user_id = 13527 AND hidden=FALSE;
    num_posts = Deal.where('user_id=? AND hidden=FALSE',self.id).count
    self.deals_num = num_posts
    self.save
    return num_posts
  end

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
    return nil if first_name.blank? && last_name.blank?
    "#{first_name} #{last_name}"
  end
  
  def best_name
    '@'+username || name
  end
  
  # does not create feedlets, only created on new deal create
  def follow!(target)
    relationships.create(:target => target)
  end
  
  # relationship destroy callback handles feedlet cleanup
  def unfollow!(target)
    relationships.find_by_target_id(target.id).try(:destroy)
  end
  
  def following?(target)
    relationships.exists?(:target_id => target.id)
  end
  
  def email_invitation_sent?(email)
    invitations_sent.exists?(:service => "email", :email => email)
  end
  
  def as_json(options={})
    options ||= {}
    options.reverse_merge!(:deals => false, :comments => false)
    
    unless options[:minimal]
      json = {
        :user_id               => id.try(:to_s),
        :first_name            => first_name.try(:to_s),
        :last_name             => last_name.try(:to_s),
        :user_name             => username.try(:to_s),
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
        :socialyzer_enabled    => socialyzer_enabled?,
        :socialyzer_ready      => socialyzer_ready?,
        :followers_count       => followers_count,
        :following_count       => following_count,
        :phone                 => phone,
        :website               => website,
        :location              => location,
  
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
        
      }
    else
      json = {
        :user_id               => id.try(:to_s),
        :first_name            => first_name.to_s,
        :last_name             => last_name.to_s,
        :user_name             => username.to_s,
        #:photo                 => photo.url(:iphone).try(:to_s),
        :photo_2x              => photo.url(:iphone2x).to_s
      }
    end
    
    unless options[:minimal]
        json[:paypal_email] = paypal_email
      
        # counts
        json[:like_count] = likes_count
        json[:deal_count] = deals_num
        json[:comment_count] = comments_count
        json[:transaction_count] = transactions_count
        json[:deals] = options[:deals]  ? deals.sorted.public.limit(20).as_json(:minimal=>true) : nil
        #is this really necessary?
        #json[:liked_deals] = options[:deals]    ? liked_deals.sorted.limit(6) : nil
        json[:comments] = options[:comments] ? comments.limit(6).as_json(:minimal=>true) : nil
        
        json[:events] = options[:events]   ? events.public.limit(20).as_json(:minimal=>true) : nil
        
      end
    

    unless options[:minimal]
      # add is_following and is_followed if possible
      if current_user = options[:current_user] 
        if current_user == self
          json[:email] = email
  
          # add the cached facebook page and token if present
          json[:current_facebook_page_id] = current_facebook_page_id if current_facebook_page_id.present?
          json[:facebook_access_token] = facebook_access_token if facebook_access_token.present?
          json[:facebook_id] = self.facebook_id if facebook_id.present?
        else
          json[:is_following] = current_user.following?(self)
          json[:is_followed] = self.following?(current_user)
        end
      end
    end

    json
  end

  def twitter_client
    Twitter.configure do |config|
      config.consumer_key = Qwiqq.twitter_consumer_key
      config.consumer_secret = Qwiqq.twitter_consumer_secret
    end
    
    @twitter_client = Twitter::Client.new(
      oauth_token: twitter_access_token, 
      oauth_token_secret: twitter_access_secret)
  end

  def foursquare_client
    @foursquare_client ||= Skittles.client(:access_token => foursquare_access_token)
  end
  
  def twitter_follower_ids
    twitter_ids = []
    results = twitter_client.follower_ids
    twitter_ids = results.attrs[:ids].map {|f| f.to_s } if results
    twitter_ids
  end

  def follower_ids(*args)
    num_attempts = 0
    begin
      num_attempts += 1
      cursor_from_response_with_user(:ids, nil, :get, "/1.1/followers/ids.json", args, :friend_ids)
    rescue Twitter::Error::TooManyRequests => error
      if num_attempts % 3 == 0
        sleep(15*60) # minutes * 60 seconds
        retry
      else
        retry
      end
    end
  end

  def socialyzer_enabled?
    !!socialyzer_enabled_at
  end

  # If false, check with Socialyzer API and update if appropriate
  #
  def socialyzer_ready?
    if twitter_id.present? and socialyzer_enabled?
      socialyzer_times.present? || engage_socialyzer!
    end
  end

  def engage_socialyzer!(force_update=false)
    if (socialyzer_times.present? && force_update) || socialyzer_times.blank?
      times_hash = Socialyzer.daily_best(twitter_id)
      unless times_hash.nil? or times_hash.empty?
        self.socialyzer_times = times_hash
        save
      end
    end
    get_twitter_utc_offset
    self.socialyzer_times.present?
  end

  def get_twitter_utc_offset
    return (self.twitter_utc_offset || -5) if self.twitter_utc_offset.present?
    twitter_user = Socialyzer.twitter_user(twitter_id)
    if twitter_user
      update_attribute(:twitter_utc_offset, twitter_user["utc_offset"] || -5)
    end
    self.twitter_utc_offset
  end

  def enable_socialyzer!
    res = Socialyzer.add_twitter_user(twitter_id)
    if res["success"]
      touch :socialyzer_enabled_at
    else
      res
    end
  end

  def disable_socialyzer!
    puts "TEST update disable_socialyzer!"
    update_attributes(:socialyzer_times => nil, :socialyzer_enabled_at => nil, :twitter_utc_offset => nil)
  end

  def next_socialyzer_time(alerts_per_day=1)
    sorted_times = socialyzer_times.map do |dayname, timestamps|
      timestamps.split.first(alerts_per_day).map do |timestamp|
        # subtract UTC offset to compensate for Socialyzer's adding it,
        # since we return times in UTC, and randomize minutes
        DateTime.parse("#{dayname} #{timestamp}") - get_twitter_utc_offset.hours + (30-rand(60)).minutes
      end
    end.flatten.select(&:future?).sort_by(&:to_i)
    sorted_times.first
  end
  
  # can raise Facebook::InvalidAccessTokenError if token missing or invalid
  def update_photo_from_facebook
    picture_url = facebook_client.photo
    self.photo = Paperclip::RemoteFile.new(picture_url) if picture_url
  end
  
  def update_photo_from_twitter
    return if twitter_access_token.blank?
    profile_image_url = twitter_client.profile_image(:size => :original) rescue nil
    self.photo = Paperclip::RemoteFile.new(profile_image_url) if profile_image_url
  end
    
  def facebook_friends
    facebook_ids = facebook_client.friends.map{|f| f["id"].to_s }
    self.class.sorted.where(:facebook_id => facebook_ids).order("first_name, last_name DESC")
  end
  
  # see lib/facebook
  def facebook_client
    client = Facebook.new(self)

    if self.sent_facebook_push == false
      #insert friend finding code
      puts "TESTING THE CODE"
      facebook_ids = client.friends.map{|f| f["id"].to_s }
      array_to_push = self.class.sorted.where(:facebook_id => facebook_ids).order("first_name, last_name DESC")
      array_to_push.each do |user_send|
        device_tokens = user_send.push_devices.map(&:token)
        next if device_tokens.blank?
        puts "CREATE BADGE"
        badge         = user_send.events.unread.count
        fb_name          = client.me["name"].to_s #CHECK
        notification  = { :device_tokens => device_tokens,
                      :page => "users/#{self.id}",
                      :aps => { :alert  => "Your Facebook friend #{fb_name} just joined Qwiqq as @#{self.username}.", 
                                :badge  => badge}}
        puts "Done sending push notification" if Urbanairship.push(notification)
        Mailer.facebook_push(user_send, self, fb_name).deliver if user_send.send_notifications
        user_send.events.create(
          :event_type => "push", 
          :user => user_send, 
          :created_by => self,
          :metadata => { :body => fb_name } 
        )

      end  
    self.sent_facebook_push = true
    save
    end
    client
  end
  
  # Temp fix for issue with reset_counters, does not work for has many through
  def update_relationship_cache
    write_attribute(:followers_count, followers.count)
    write_attribute(:following_count, following.count)
    save
  end
  
  private
    # note use of update_column over update_attribute
    # facebook_client will handle exception and clear facebook_access_token if appropriate
    # TODO refactor all this dup code
    def update_facebook_id
      return unless self.facebook_access_token_changed?
      return if self.facebook_access_token.blank?
      
      facebook_user = self.facebook_client.me
      self.facebook_id = facebook_user["id"] if facebook_user
            
    rescue Exception => e
      Rails.logger.error "User#update_facebook_id: #{e.message}"
    end
    
    def update_twitter_id
      return unless twitter_access_token_changed?
      return if twitter_access_token.blank?
      
      twitter_user = twitter_client.user
      self.twitter_id = twitter_user.id.to_s if twitter_user
      
    rescue Exception => e
      Rails.logger.error "User#update_twitter_id: #{e.message}"
    end
    
    def update_foursquare_id
      return unless foursquare_access_token_changed?
      return if foursquare_access_token.blank?
      
      foursquare_user = foursquare_client.user("self")
      self.foursquare_id =  foursquare_user["id"] if foursquare_user
      
    rescue Exception => e
      Rails.logger.error "User#update_foursquare_id: #{e.message}"      
    end
    
    # called on after_save
    # will either create device record and register
    # or register existing device
    def update_push_token
      return if push_token.blank?
      search = String.new(push_token)
      puts "String:#{search}"
      search = search.upcase
      search = search.gsub!(/\s+/, "")
      @device = PushDevice.where(:token => search).first
      puts "Test push token:#{search} if push device exists:#{@device}"
      unless @device.nil?
        Urbanairship.unregister_device(search)
        puts "Remove this token:#{@device}"
        @device.destroy
        puts 'Destroyed old device'
      end
      PushDevice.create_or_update!(:token => push_token, :user_id => self.id)
      puts 'created new push device'
      push_token = nil
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
    
    # TODO fix, currently not working
    def async_update_cached_user_attributes
      Resque.enqueue(UpdateCachedUserAttributesJob, id) if photo_file_name_changed?
    end
end

