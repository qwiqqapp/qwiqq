require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    Resque.reset!
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
  end

  #------ twitter
  test "should a message provided to be provided" do
    @share = Factory(:twitter_share, :message => "I found a thing on qwiqq!")
    url = Rails.application.routes.url_helpers.deal_url(@share.deal, :host => "qwiqq.me")
    assert_equal "I found a thing on @Qwiqq! #{@share.deal.name} #{url}", @share.message
    assert_queued(ShareDeliveryJob, [@share.id])
  end
    
  # test queue is populated
  test "should queue twitter share" do
    @share = Factory(:twitter_share)
    assert_not_nil @share.message
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
  
  test "should deliver an sms share" do
    Twilio::REST::Messages.any_instance.expects(:create).once.returns(nil)
    @share = Factory(:sms_share)
    assert_queued(ShareDeliveryJob, [@share.id])
    Resque.run!
  end
  
  test "should create a 'share' event on creation" do
    @owner = Factory(:user)
    @sharer = Factory(:user)
    @deal = Factory(:deal, :user => @owner)
    @share = Factory(:twitter_share, :deal => @deal, :user => @sharer)
  
    assert_equal 1, @owner.events.size
    assert_equal "share", @owner.events[0].event_type
    assert_equal "twitter", @owner.events[0].metadata[:service]
    assert_equal @sharer, @owner.events[0].created_by
    assert_equal @deal, @owner.events[0].deal
  end
  
  # ------- facebook
  test "should queue share deliver job" do
    @share = Factory(:facebook_share)
    assert_queued(ShareDeliveryJob, [@share.id])
  end
  
  test "should share a deal to facebook" do
    @share = Factory(:facebook_share)
    
    client = mock
    client.expects(:share_link).with(@share)
    User.any_instance.expects(:facebook_client).returns(client)
    
    Resque.run!
  end
  
  test "should update shared_at on success" do
    @share = Factory(:facebook_share)
    
    client = mock
    client.expects(:share_link).with(@share)
    User.any_instance.expects(:facebook_client).returns(client)
    
    Resque.run!
    @share.reload
    assert_not_nil @share.shared_at
  end
  
  test "should not rescue from Koala exception" do
    @share = Factory(:facebook_share)
    
    client = mock
    client.expects(:share_link).with(@share).raises(Koala::Facebook::APIError)
    User.any_instance.expects(:facebook_client).returns(client)
    
    assert_raises Koala::Facebook::APIError do
      Resque.run!
    end
  end
end

