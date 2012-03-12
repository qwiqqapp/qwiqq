require 'test_helper'

class PushDeviceTest < ActiveSupport::TestCase
  
  setup do
    PushDevice.any_instance.stubs(:register).returns(true)
    PushDevice.any_instance.stubs(:unregister).returns(true)
  end
  
  test "should accept raw token and convert to upcase and remove spaces" do
    token   = 'aaaaaaaa bbbbbbbb 4e924598 74107351 6f0c032f 3c017918 1c9cd79e 1c9cd79e'
    @device = Factory(:push_device, :token => token)
    assert_match(/^AAAAAAAABBBBBBBB/, @device.token)
  end
  
  test "should create with valid token (77BAFBCAD01C6...)" do
    token = '77BAFBCAD01C6BDB5E18C08520EACAFBE14EFD4BCEBA289E03652104A58AAE0E'
    @device = Factory(:push_device, :token => token)
    assert @device.valid?
  end
  
  test "should create with valid token (b0a91911 db6fad5f 4e924...)" do
    token = 'b0a91911 db6fad5f 4e924598 74107351 6f0c032f 3c017918 1c9cd79e 1c9cd79e'
    @device = Factory(:push_device, :token => token)
    assert @device.valid?
  end
  
  test "should NOT create with invalid token (sadfsfdsdfsfd)" do
    token = 'sadfsfdsdfsfd'    
    exception = assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:push_device, :token => token)
    }
    assert_match(/token/i, exception.message)
  end
end
