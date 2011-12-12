class PushDevice < ActiveRecord::Base
  
  belongs_to :user
  
  validates :token, 
    :presence   => true, 
    :uniqueness => true,
    :format     => {  
      :with => /^[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}$/ 
    }
  
  after_save :register
  before_destroy :unregister
  
  def register
    update_attribute(:last_registered_at, Time.now) if Urbanairship.register_device(self.token)
  end
  
  private
  def unregister
    Urbanairship.unregister_device(self.token)
  end
end