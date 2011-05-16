class User < ActiveRecord::Base
  
  has_many :deals
  has_many :comments
  
  scope :today, lambda{ where('DATE(created_at) = ?', Date.today)}
  
  attr_accessible :name, :email, :password, :password_confirmation, :photo, :country, :city

  attr_accessor :password
  before_save   :encrypt_password

  validates_confirmation_of :password
  validates_presence_of     :password, :on => :create
  validates_presence_of     :email
  validates_uniqueness_of   :email
  
  has_attached_file :photo, 
                    {:styles => { :admin    => ["30x30#", :jpg],
                                  :iphone   => ["75x75#", :jpg],
                                  :iphone2x => ["150x150#", :jpg]}
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
  
  def as_json(options={})
    {
      :email      => email,
      :name       => name,
      :city       => city,
      :country    => country,
      :created_at => created_at,
      :created_at => updated_at,
      :photo      => photo.url(:iphone),
      :photo_2x   => photo.url(:iphone2x)
    }
  end
  
  
  
  
end