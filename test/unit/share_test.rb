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
    url = Rails.application.routes.url_helpers.deal_url(@share.deal, :host => "staging.qwiqq.me")
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
  test "should deliver share to users facebook timeline" do
    @share = Factory(:facebook_share, :user => Factory(:user), :facebook_page_id => '')
    
    facebook_client = mock
    facebook_client.expects(:put_connections).with("me", "qwiqqme:share", anything).returns(true)
    User.any_instance.expects(:facebook_client).returns(facebook_client)
    
    Resque.run!
  end
  
  test "should share a deal to a users facebook page" do
    @share = Factory(:facebook_share, :facebook_page_id => "3234592348234")

    facebook_client = mock
    facebook_client.expects(:put_connections).with("3234592348234", "qwiqqme:share", anything).returns(true)
    User.any_instance.expects(:facebook_client).returns(facebook_client)

    Resque.run!
  end
  
  test "should queue share deliver job" do
    @share = Factory(:facebook_share)
    assert_queued(ShareDeliveryJob, [@share.id])
  end
  
  test "should update shared_at on success" do
    @share = Factory(:facebook_share)

    facebook_client = mock
    facebook_client.expects(:put_connections).returns(true)
    User.any_instance.expects(:facebook_client).returns(facebook_client)
    
    Resque.run!
    @share.reload
    assert_not_nil @share.shared_at
  end
  
  test "should set a default message when none is provided (facebook)" do
    @share = Factory(:facebook_share)

    facebook_client = mock
    facebook_client.expects(:put_connections).returns(true)
    User.any_instance.expects(:facebook_client).returns(facebook_client)
    
    Resque.run!
    assert_equal "I shared something I love on Qwiqq!", @share.message
  end
  
  
  test "should not resque from Koala exception" do
    @share = Factory(:facebook_share)
    
    facebook_client = mock
    facebook_client.expects(:put_connections).raises(Koala::Facebook::APIError)
    User.any_instance.expects(:facebook_client).returns(facebook_client)
    
    assert_raises Koala::Facebook::APIError do
      Resque.run!
    end
  end
end

