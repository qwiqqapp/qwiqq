require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    stub_indextank
  end
  
  def teardown
    Resque.reset!
  end
  
  # -------
  # index tank
  test "should sync deal with indextank on create" do
    Qwiqq::Indextank::Document.any_instance.expects(:sync_variables).once
    @like = Factory(:like)
  end
  
  test "should sync deal with indextank on destroy" do
    @like = Factory(:like)
    Qwiqq::Indextank::Document.any_instance.expects(:sync_variables).once
    @like.destroy
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
  
  test "should update sent_at" do
    @owner  = Factory(:user, :send_notifications => true)
    @deal   = Factory(:deal, :user => @owner)
    @like   = Factory(:like, :deal => @deal)
    
    Resque.run!
    assert_not_nil Like.find(@like.id).notification_sent_at
  end
  
  # -------------------
  # should not send
  
  test "should NOT send notification if DISABLED for user" do
    @owner  = Factory(:user, :send_notifications => false)
    @deal   = Factory(:deal, :user => @owner)
    @like   = Factory(:like, :deal => @deal)
    
    Mailer.expects(:deal_liked).never
    Resque.run!
    
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
end
