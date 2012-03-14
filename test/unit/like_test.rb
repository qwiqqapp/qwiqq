require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    Resque.reset!
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
  end
  
  # ------
  #  queues and execution
  
  test "should queue like notification delivery" do
    @like = Factory(:like)
    assert_nil @like.notification_sent_at
    assert_queued(LikeNotifyJob, [@like.id])
  end
  
  test "should send notification if enabled for user" do
    @owner  = Factory(:user, :send_notifications => true)
    @deal   = Factory(:deal, :user => @owner)
    @like   = Factory(:like, :deal => @deal)
    
    Mailer.expects(:deal_liked).once.with(@owner, @like).returns(mock(:deliver => true))
    Resque.run!
  end


  test "should send notification" do
    @owner  = Factory(:user, :send_notifications => true)
    @deal   = Factory(:deal, :user => @owner)
    @like   = Factory(:like, :deal => @deal)
    
    Resque.run!
    email = ActionMailer::Base.deliveries.last
    assert_match(/liked/i, email.subject)
  end
  
  test "should update sent_at" do
    @owner  = Factory(:user, :send_notifications => true)
    @deal   = Factory(:deal, :user => @owner)
    @like   = Factory(:like, :deal => @deal)
    
    Resque.run!
    @like.reload
    assert_not_nil @like.notification_sent_at
  end
  
  # -------------------
  # should not send

  test "should NOT raise exception for like+unlike record not found" do
    @owner  = Factory(:user, :send_notifications => false)
    @deal   = Factory(:deal, :user => @owner)
    Resque.reset! ## <<< temp fix, share job is being created from @user factory
    
    @like = Factory(:like, :deal => @deal)
    @like.destroy #user unlikes deal
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      Resque.run!
    end
  end

  test "should NOT send notification if DISABLED for user" do
    @owner  = Factory(:user, :send_notifications => false)
    @deal   = Factory(:deal, :user => @owner)
    @like   = Factory(:like, :deal => @deal)
    
    Mailer.expects(:deal_liked).never
    Resque.run!
    @like.reload
    assert_nil @like.notification_sent_at
  end
  
  test "should NOT send notification twice" do
    @owner  = Factory(:user, :send_notifications => true)
    @deal   = Factory(:deal, :user => @owner)
    @like   = Factory(:like, :deal => @deal)
    
    # another process sends notification
    @like.update_attribute(:notification_sent_at, Time.now - 1.hour)
    
    Mailer.expects(:deal_liked).never
    Resque.run!
  end

  test "should create a 'like' event on creation" do
    @owner = Factory(:user)
    @liker = Factory(:user)
    @deal = Factory(:deal, :user => @owner)
    @like = Factory(:like, :deal => @deal, :user => @liker)

    assert_equal 1, @owner.events.size
    assert_equal "like", @owner.events[0].event_type
    assert_equal @liker, @owner.events[0].created_by
    assert_equal @deal, @owner.events[0].deal
  end
end

