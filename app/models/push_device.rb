# example valid token: 
# b0a91911 db6fad5f 4e924598 74107351 6f0c032f 3c017918 1c9cd79e a2ec144c

class PushDevice < ActiveRecord::Base
  belongs_to :user
  
  before_destroy :unregister
  
  validates :token,
    :presence   => true,
    :uniqueness => true,
    :format     => {
      :with => /^[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}$/
    }
  
  #  find device based on user_id and token or create new record
  # register device with urbanairhip
  def self.create_or_update!(opts={})
    device = where(opts).first || create!(opts)
    device.register
    
  rescue ActiveRecord::RecordInvalid => e  
    Rails.logger.info("PushDevice#create_or_update: #{e.message} #{opts.inspect}")
  end

  def register
    response = Urbanairship.register_device(self.token)
    if response
      update_attribute(:last_registered_at, Time.now)
    else
      Rails.logger.info("[Urbanairship] PushDevice#register: Failed to register device #{self.token}")
    end
  end
  
  private
  def unregister
    response = Urbanairship.unregister_device(self.token)
    Rails.logger.info("[Urbanairship] PushDevice#unregister: Failed to remove device #{self.token}") unless response
    true # always return true, otherwise halts delete
  end
end

