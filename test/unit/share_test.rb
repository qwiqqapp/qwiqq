require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    Resque.reset!
  end
  
  # test queue is populated
  test "should queue twitter share" do
    @share = Factory(:twitter_share)
    assert_queued(ShareDeliveryJob, [@share.id])
  end
  
  # test result of queued jobs
  test "should deliver shared deal to email" do
    @target_email = 'adam@test.com'
    @share = Factory(:email_share, :email => @target_email)

    assert_queued(ShareDeliveryJob, [@share.id])
    
    Mailer.expects(:share_deal).once.with(@target_email, @share).returns(mock(:deliver => true))
    Resque.run!
  end
  
  test "should send shared deal to facebook" do
    @share = Factory(:facebook_share)
    assert_queued(ShareDeliveryJob, [@share.id])
    
    User.any_instance.expects(:share_deal_to_facebook).once.with(@share.deal)
    Resque.run!
  end
  
  test "should NOT share deal to facebook twice" do 
    @share = Factory(:facebook_share)
    assert_queued(ShareDeliveryJob, [@share.id])
    
    # another process shares deal
    @share.update_attribute(:shared_at, Time.now - 1.hour)
    
    User.any_instance.expects(:share_deal_to_facebook).never
    Resque.run!
  end
end
