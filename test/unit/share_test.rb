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
  
  test "should send shared deal to facebook immediately" do
    facebook_client = mock
    facebook_client.expects(:put_wall_post).returns(true)

    @user = Factory(:user)
    @user.expects(:facebook_client).returns(facebook_client)
    @share = Factory(:facebook_share, :user => @user)

    # facebook shares are not queued
    assert_not_queued(ShareDeliveryJob, [@share.id])

    # share should be saved on success
    assert @share.persisted?
    assert_not_nil @share.shared_at
  end

  test "should not persist when sharing to facebook fails due to an invalid access token" do
    facebook_client = mock
    facebook_client.expects(:put_wall_post).raises(Koala::Facebook::APIError.new(
      :type => "OAuthException", 
      :message => "Error validating access token: The session has been invalidated because the user has changed the password."))

    @user = Factory(:user)
    @user.expects(:facebook_client).returns(facebook_client)
    @share = Factory.build(:facebook_share, :user => @user)
    
    assert_raises Koala::Facebook::APIError do
      @share.save
    end

    # share should not be saved on failure
    assert !@share.persisted?
  end

  test "should deliver an sms share" do
    Twilio::REST::Messages.any_instance.expects(:create).once.returns(nil)
    @share = Factory(:sms_share)
    assert_queued(ShareDeliveryJob, [@share.id])
    Resque.run!
  end
end

