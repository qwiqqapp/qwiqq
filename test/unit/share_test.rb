require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  
  setup do
    stub_indextank
  end
  
  test "should send email notification when service is email" do
    @target_email = 'adam@test.com'
    @share        = Share.new(:user => Factory(:user), :deal => Factory(:deal), :email => @target_email, :service => 'email')
    
    Mailer.expects(:share_deal).once.with(@target_email, @share).returns(mock(:deliver => true))
    @share.save
  end
  
end
