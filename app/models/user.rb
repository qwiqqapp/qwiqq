class User < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  has_many :deals,    :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :likes,    :dependent => :destroy
  has_many :liked_deals, :through => :likes, :source => :deal

  has_many :friendships, :dependent => :destroy 

  has_many :friends, :class_name => "User", 
    :finder_sql  => proc { "SELECT users.*  FROM users WHERE users.id IN (#{select_friend_ids_sql})" },
    :counter_sql => proc { "SELECT COUNT(*) FROM users WHERE users.id IN (#{select_friend_ids_sql})" }

  has_many :pending_friends, :through => :friendships, :source => :friend, :conditions => "friendships.status = #{Friendship::PENDING}"
  has_many :rejected_friends, :through => :friendships, :source => :friend, :conditions => "friendships.status = #{Friendship::REJECTED}"
  
  scope :today, lambda{ where('DATE(created_at) = ?', Date.today)}
  
  attr_accessible :first_name, :last_name, :username, :email, :password, :password_confirmation, :photo, :country, :city
  
  attr_accessor :password
  before_save   :encrypt_password
  
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
  
  def create_friendship(friend)
    friendships.create(:friend_id => friend.id)
  end
  
  def as_json(options={})
    options.reverse_merge!(:deals => false, :comments => false)
    {
      :user_id        => id.try(:to_s),
      :email          => email,
      :first_name     => first_name,
      :last_name      => last_name,
      :user_name      => username,
      :city           => city,
      :country        => country,
      :created_at     => created_at,
      :updated_at     => updated_at,
      :join_date      => created_at.to_date.to_s(:long),
      
      # user detail photo
      :photo          => photo.url(:iphone),
      :photo_2x       => photo.url(:iphone2x),
      
      # user detail photo zoom
      :photo_zoom     => photo.url(:iphone_zoom),
      :photo_zoom_2x  => photo.url(:iphone_zoom_2x),
      
      # counts
      :like_count     => liked_deals.count,
      :deal_count     => deals.count,
      :comment_count  => comments.count,
      
      # conditional
      :deals          => options[:deals]    ? deals.limit(6)        : nil,
      :liked_deals    => options[:deals]    ? liked_deals.limit(6)  : nil,
      :comments       => options[:comments] ? comments.limit(3)     : nil
    }
  end

  private
    def select_friend_ids_sql(status = Friendship::ACCEPTED)
      # friendship is bi-directional through a single entry in friendships
      "SELECT friendships.user_id AS user_id FROM friendships 
         WHERE (friendships.friend_id = #{id} AND friendships.status = #{status}) UNION
       SELECT friendships.friend_id AS user_id FROM friendships 
         WHERE (friendships.user_id = #{id} AND friendships.status = #{status})"
    end
end

