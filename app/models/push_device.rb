class PushDevice < ActiveRecord::Base
  belongs_to :user
  
  validates :token, 
    :presence   => true, 
    :uniqueness => true,
    :format     => {  
      :with => /^[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}$/
    }
  
  after_create :register
  before_destroy :unregister
  
  def token=(token)
    res = token.scan(/\<(.+)\>/).first
    unless res.nil? || res.empty?
      token = res.first
    end
    write_attribute('token', token)
  end
  
  def register
    update_attribute(:last_registered_at, Time.now) if Urbanairship.register_device(self.token)
  end
  
  private
  def unregister
    response = Urbanairship.unregister_device(self.token)
    Rails.logger.info("PushDevice#unregister: Failed to unregister device #{self.token} from Urbanairship") unless response
    true # always return true, otherwise halts delete
  end
end

