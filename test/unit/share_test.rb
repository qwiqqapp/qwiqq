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

  test "should a message provided to be provided" do
    @share = Factory(:twitter_share, :message => "I found a thing on qwiqq!")
    url = Rails.application.routes.url_helpers.deal_url(@share.deal, :host => "staging.qwiqq.me")
    assert_equal "I found a thing on @Qwiqq! #{@share.deal.name} #{url}", @share.message
    assert_queued(ShareDeliveryJob, [@share.id])
  end
  
  test "should set a default message when none is provided" do
    facebook_client = mock
    facebook_client.expects(:put_wall_post)
    @user = Factory(:user)
    @user.expects(:facebook_client).returns(facebook_client)
    @share = Factory(:facebook_share, :user => @user)
    assert_equal "I shared something I love on Qwiqq!", @share.message
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
  
  test "should send shared deal to facebook" do
    facebook_client = mock
    facebook_client.expects(:put_wall_post).with(anything, anything, "me").returns(true)

    @user = Factory(:user)
    @user.expects(:facebook_client).returns(facebook_client)
    @share = Factory(:facebook_share, :user => @user)

    assert_queued(ShareDeliveryJob, [@share.id])

    # share should be saved on success
    assert @share.persisted?
    assert_not_nil @share.shared_at
    assert_not_nil @share.message
  end

  # test "should share a deal to a facebook page" do
  #   facebook_client = mock
  #   facebook_client.expects(:put_wall_post).with(anything, anything, "3234592348234").returns(true)
  # 
  #   @user = Factory(:user)
  #   @user.expects(:facebook_client).returns(facebook_client)
  #   @share = Factory(:facebook_share, :user => @user, :facebook_page_id => "3234592348234")
  # 
  #   # facebook shares are not queued
  #   assert_not_queued(ShareDeliveryJob, [@share.id])
  # 
  #   # share should be saved on success
  #   assert @share.persisted?
  #   assert_not_nil @share.shared_at
  #   assert_not_nil @share.message
  # end

  # test "should not persist when sharing to facebook fails due to an invalid access token" do
  #   facebook_client = mock
  #   facebook_client.expects(:put_wall_post).raises(Koala::Facebook::APIError.new(
  #     :type => "OAuthException", 
  #     :message => "Error validating access token: The session has been invalidated because the user has changed the password."))
  # 
  #   @user = Factory(:user)
  #   @user.expects(:facebook_client).returns(facebook_client)
  #   @share = Factory.build(:facebook_share, :user => @user)
  #   
  #   assert_raises Koala::Facebook::APIError do
  #     @share.save
  #   end
  # 
  #   # share should not be saved on failure
  #   assert !@share.persisted?
  # end


end

