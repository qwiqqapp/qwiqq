class User < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include Qwiqq::FacebookSharing
  include Qwiqq::TwitterSharing
  
  has_many :deals,    :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :likes,    :dependent => :destroy
  has_many :liked_deals, :through => :likes, :source => :deal

  has_many :relationships, :dependent => :destroy
  has_many :inverse_relationships, :class_name => "Relationship", :foreign_key => "target_id"
    
  has_many :following, :through => :relationships, :source => :target
  has_many :followers, :through => :inverse_relationships, :source => :user
  has_many :friends, :class_name => "User", 
    :finder_sql => proc { 
      "SELECT users.* FROM users WHERE id IN (
         SELECT r1.target_id FROM relationships r1, relationships r2 
         WHERE r1.user_id = r2.target_id AND r1.target_id = r2.user_id AND r1.user_id = #{id})" },
    :counter_sql => proc { 
      "SELECT COUNT(*) FROM relationships r1, relationships r2 
       WHERE r1.user_id = r2.target_id AND r1.target_id = r2.user_id AND r1.user_id = #{id}" }

  has_many :shares, :dependent => :destroy
  has_many :shared_deals, :through => :shares, :source => :deal, :uniq => true
  
  has_many :reposted_deals, :dependent => :destroy
  has_many :reposts, :class_name => "Deal", :through => :reposted_deals, :source => :user

  has_many :invitations_sent, :class_name => "Invitation"

  # queried using AREL so that it can be more easily extended;
  #   e.g user.feed_deals.include(:category).limit(20)
  def feed_deals
    Deal.
      joins("LEFT OUTER JOIN relationships ON relationships.target_id = deals.user_id").
      where("relationships.user_id = #{id} OR deals.user_id = #{id}")
  end
  
  # unable to use search due to meta_search in active admin
  scope :search_by_username, lambda { |query| where([ 'UPPER(username) like ?', "%#{query.upcase}%" ]) }  
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
    
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
                  :send_notifications, 
                  :bio
  
  attr_accessor :password

  before_save :encrypt_password
  before_save :update_twitter_id
  before_save :update_facebook_id
  
  validates_confirmation_of :password
  validates_presence_of     :password, :on => :create
  validates_presence_of     :email, :username
  validates_uniqueness_of   :email, :username
  
  # see initializers/auto_orient.rb for new processor
  has_attached_file :photo,
                    { :processors => [:auto_orient, :thumbnail],
                      :styles => { :admin_sml    => ["30x30#", :jpg],
                                  :admin_med    => ["50x50#", :jpg],
                                  :admin_lrg    => ["240x", :jpg],
                                  
                                  :iphone       => ["75x75#", :jpg],
                                  :iphone2x     => ["150x150#", :jpg],
                                  
                                  :iphone_zoom       => ["300x300#", :jpg],
                                  :iphone_zoom_2x    => ["600x600#", :jpg]}
                    }.merge(PAPERCLIP_STORAGE_OPTIONS)


  strip_attrs :email, :city, :country, :first_name, :last_name, :username, :bio
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
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
    relationships.create(:target => target)
  end

  def unfollow!(target)
    relationships.find_by_target_id(target.id).try(:destroy)
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

  def repost_deal!(deal)
    reposted_deals.create(:deal => deal)
  end

  def email_invitation_sent?(email)
    invitations_sent.exists?(:service => "email", :email => email)
  end
  
  def feed_deals
    # finds the users deals, reposts, followed user deals and followed user reposts
    Deal.joins("LEFT OUTER JOIN relationships ON relationships.target_id = deals.user_id").
         joins("LEFT OUTER JOIN reposted_deals ON reposted_deals.deal_id = deals.id").
         where("relationships.user_id = #{id} OR 
                deals.user_id = #{id} OR 
                reposted_deals.user_id = #{id} OR 
                reposted_deals.user_id IN(
                  SELECT relationships.target_id FROM relationships WHERE relationships.user_id = #{id})")
  end

  def as_json(options={})
    options ||= {}
    options.reverse_merge!(:deals => false, :comments => false)
    json = {
      :user_id             => id.try(:to_s),
      :email               => email,
      :first_name          => first_name,
      :last_name           => last_name,
      :user_name           => username,
      :city                => city,
      :bio                 => bio,
      :country             => country,
      :created_at          => created_at,
      :updated_at          => updated_at,
      :join_date           => created_at.to_date.to_s(:long),
      :send_notifications  => send_notifications,
      :facebook_authorized => !facebook_access_token.blank?,
      :twitter_authorized  => !twitter_access_token.blank?,
      :followers_count     => followers_count,
      :following_count     => following_count,
      :friends_count       => friends_count,

      # user detail photo
      :photo               => photo.url(:iphone),
      :photo_2x            => photo.url(:iphone2x),
      
      # user detail photo zoom
      :photo_zoom          => photo.url(:iphone_zoom),
      :photo_zoom_2x       => photo.url(:iphone_zoom_2x),
      
      # counts
      :like_count          => liked_deals.count,
      :deal_count          => deals.count,
      :comment_count       => comments.count,
      
      # conditional
      :deals               => options[:deals]    ? deals.limit(6)        : nil,
      :liked_deals         => options[:deals]    ? liked_deals.limit(6)  : nil,
      :comments            => options[:comments] ? comments.limit(3)     : nil
    }
    
    # add is_following and is_followed if possible
    if current_user = options[:current_user] 
      json[:is_following] = current_user.following?(self)
      json[:is_followed] = self.following?(current_user)
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

  private
    def update_twitter_id
      return unless twitter_access_token_changed?
      if !twitter_access_token.blank?
        user = twitter_client.user rescue nil
        return false unless user
        self.twitter_id = user.id.to_s
      else
        self.twitter_id = ""
      end
    end

    def update_facebook_id
      return unless facebook_access_token_changed?
      if !facebook_access_token.blank?
        account = facebook_client.get_object("me") rescue nil
        return false unless account
        self.facebook_id = account["id"] 
      else
        self.facebook_id = ""
      end
    end
end

