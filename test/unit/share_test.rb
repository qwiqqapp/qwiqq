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
  

  #------ message content
  test "should share formatted message on Twitter with custom message" do
    deal = Factory(:deal, :price => 0, :name => 'free beer', :foursquare_venue_name => "Gastown Labs")
    share = Factory(:twitter_share, :message => "sweet", :deal => deal)
    
    assert_equal "sweet - #{deal.name} Free @ #{deal.foursquare_venue_name} http://qwiqq.me/posts/#{deal.id}", share.message
    assert share.message.size < 140
  end
  
  test "should share formatted message on Twitter without custom message" do
    deal = Factory(:deal, :price => 200, :name => 'cheap beer', :foursquare_venue_name => "Six Acres")
    share = Factory(:twitter_share, :message => "", :deal => deal)
    
    assert_equal "#{deal.name} $2.00 @ #{deal.foursquare_venue_name} http://qwiqq.me/posts/#{deal.id}", share.message
    assert share.message.size < 140
  end
  
  test "should share formatted message on Foursquare with custom message" do
    deal = Factory(:deal, :price => 9000, :name => 'nice pizza', :foursquare_venue_name => "Gastown Labs")
    share = Factory(:foursquare_share, :message => "epic", :deal => deal)
    
    assert_equal "epic - #{deal.name} $90.00 http://qwiqq.me/posts/#{deal.id}", share.message
    assert share.message.size < 140
  end
  
  test "should share formatting message on SMS with custom message" do
    deal = Factory(:deal, :price => 400, :name => 'best pizza place in NY', :foursquare_venue_name => "Gastown Labs")
    share = Factory(:sms_share, :message => "sweet", :deal => deal)
    
    assert_equal "#{share.user.username}: sweet - #{deal.name} $4.00 @ #{deal.foursquare_venue_name} http://qwiqq.me/posts/#{deal.id}", share.message
    assert share.message.size < 140
  end
  
  test "should share truncated message on Twitter with LONG custom message" do
    long_message = "amazing amazing amazing pizza, get there early though there will be a looooong line!"
    deal = Factory(:deal, :price => 9000, :name => 'best pizza place in NY just over the bridge', :foursquare_venue_name => "Gastown Labs")
    share = Factory(:twitter_share, :message => long_message, :deal => deal)
    
    assert_equal "#{long_message} - bes... $90.00 @ #{deal.foursquare_venue_name} http://qwiqq.me/posts/#{deal.id}", share.message
    assert share.message.size < 140
  end
  
  test "should share formatted message via Email" do
    deal = Factory(:deal, :price => 9000, :name => 'tasty whiskey', :foursquare_venue_name => "Gastown Labs")
    share = Factory(:email_share, :message => 'test', :deal => deal)
    
    assert_equal "test - tasty whiskey $90.00 @ Gastown Labs", share.message
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

