require 'test_helper'

class PushDeviceTest < ActiveSupport::TestCase
  
  setup do
    PushDevice.any_instance.stubs(:register).returns(true)
    PushDevice.any_instance.stubs(:unregister).returns(true)
  end
  
  test "should create with valid token" do
    @device = Factory(:push_device, :token => 'b0a91911 db6fad5f 4e924598 74107351 6f0c032f 3c017918 1c9cd79e 1c9cd79e')
    assert @device.valid?
  end
  
  test "should not accept short token" do
    exception = assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:push_device, :token => 'b0a91911 db6fad5f 4e924598 74107351 6f0c032f 3c017918 1c9cd79e')
    }
    assert_match /token/i, exception.message
  end
  
  test "should not accept token without 6 spaces" do
    exception = assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:push_device, :token => 'b0a91911 db6fad5f 4e924598 74107351 6f0c032f 3c017918 1c9cd79e41c9cd79e')
    }
    assert_match /token/i, exception.message
  end
  
end
