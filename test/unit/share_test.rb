require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  
  # to allow after_commit to run
  self.use_transactional_fixtures = false
  
  def setup
    Resque.reset!
  end
  
  # test queue is populated
  test "should queue facebook share" do
    @share = Share.create(:user => Factory(:user), :deal => Factory(:deal), :service => 'facebook')
    assert_queued(ShareDeliveryJob, [@share.id])
  end
  
  # test result of queued jobs
  test "should deliver shared deal to email" do
    @target_email = 'adam@test.com'
    @share = Share.create(:user => Factory(:user), :deal => Factory(:deal), :email => @target_email, :service => 'email')
    assert_queued(ShareDeliveryJob, [@share.id])
    
    Mailer.expects(:share_deal).once.with(@target_email, @share).returns(mock(:deliver => true))
    Resque.run!
  end
  
  test "should send shared deal to facebook" do
    @user  = Factory(:user)
    @deal  = Factory(:deal)
    @share = Share.create(:user => @user, :deal => @deal, :service => 'facebook', :shared_at => nil)
    assert_queued(ShareDeliveryJob, [@share.id])
    
    User.any_instance.expects(:share_deal_to_facebook).once.with(@deal)
    Resque.run!
  end
  
  test "should NOT share deal to facebook twice" do 
    @user  = Factory(:user)
    @deal  = Factory(:deal)
    @share = Share.create(:user => @user, :deal => @deal, :service => 'facebook', :shared_at => nil)
    assert_queued(ShareDeliveryJob, [@share.id])
    
    # another process shares deal
    @share.update_attribute(:shared_at, Time.now - 1.hour)
    
    User.any_instance.expects(:share_deal_to_facebook).never
    Resque.run!
  end
  
end
