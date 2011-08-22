require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    Resque.reset!
    stub_indextank
  end
  
  teardown do
    Comment.destroy_all
  end
  
  test "strips body before saving" do
    @comment = Factory(:comment, :body => "        body      ")
    assert_equal "body", @comment.body
  end
  
  test "should queue comment notification delivery" do
    @comment = Factory(:comment)
    assert_nil @comment.notification_sent_at
    assert_queued(CommentNotifyJob, [@comment.id])
  end
  
  test "should send notification if enabled for user" do
    @owner    = Factory(:user, :send_notifications => true)
    @deal     = Factory(:deal, :user => @owner)
    @comment  = Factory(:comment, :deal => @deal)
    
    Mailer.expects(:deal_commented).once.with(@owner, @comment).returns(mock(:deliver => true))
    Resque.run!
  end
  
  test "should update sent_at" do
    @owner  = Factory(:user, :send_notifications => true)
    @deal   = Factory(:deal, :user => @owner)
    @comment   = Factory(:comment, :deal => @deal)
    
    Resque.run!
    assert_not_nil Comment.find(@comment.id).notification_sent_at
  end
  
  
  # -------------------
  # should not send
  
  test "should NOT send notification if DISABLED for user" do
    @owner    = Factory(:user, :send_notifications => false)
    @deal     = Factory(:deal, :user => @owner)
    @comment  = Factory(:comment, :deal => @deal)
    
    Mailer.expects(:deal_commented).never
    Resque.run!
    
    assert_nil @comment.notification_sent_at
  end
  
  test "should NOT send notification twice" do
    @owner  = Factory(:user, :send_notifications => true)
    @deal   = Factory(:deal, :user => @owner)
    @comment   = Factory(:comment, :deal => @deal)
    
    # another process sends notification
    @comment.update_attribute(:notification_sent_at, Time.now - 1.hour)
    
    Mailer.expects(:deal_commented).never
    Resque.run!
  end
end
