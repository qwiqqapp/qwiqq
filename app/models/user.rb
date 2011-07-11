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

  has_many :invitations_sent, :class_name => "Invitation"
  
  # added using AREL so that the query can more easily be extended;
  #   e.g user.following_deals.include(:category).limit(20)
  def following_deals
    Deal.joins("INNER JOIN relationships ON relationships.target_id = deals.user_id").where("relationships.user_id = #{id}")
  end
  
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
  validates_presence_of     :email
  validates_uniqueness_of   :email, :username
  
  has_attached_file :photo, 
                    {:styles => { :admin_sml    => ["30x30#", :jpg],
                                  :admin_med    => ["50x50#", :jpg],
                                  :admin_lrg    => ["240x", :jpg],
                                  
                                  :iphone       => ["75x75#", :jpg],
                                  :iphone2x     => ["150x150#", :jpg],
                                  
                                  :iphone_zoom       => ["300x300#", :jpg],
                                  :iphone_zoom_2x    => ["600x600#", :jpg]
                                  }
                    }.merge(PAPERCLIP_STORAGE_OPTIONS)
  
  def self.authenticate!(email, password)
    user = find_by_email!(email)
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
    # TODO do this by extending #friends
    Relationship.find_by_sql(
        "SELECT r1.* FROM relationships r1, relationships r2 
         WHERE r1.user_id = r2.target_id AND r1.target_id = r2.user_id 
           AND r1.user_id = #{id} AND r1.target_id = #{target.id}").any?
  end

  def email_invitation_sent?(email)
    invitations_sent.exists?(:service => "email", :email => email)
  end
  
  def as_json(options={})
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
    @twitter_client ||= TwitterOAuth::Client.new(
      :consumer_key => Qwiqq.twitter_consumer_key, 
      :consumer_secret => Qwiqq.twitter_consumer_secret,
      :token => twitter_access_token,
      :secret => twitter_access_secret)
  end

  private
    def update_twitter_id
      return unless twitter_access_token_changed?
      if !twitter_access_token.blank?
        return false unless twitter_client.authorized?
        self.twitter_id = twitter_client.info["id"] 
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

