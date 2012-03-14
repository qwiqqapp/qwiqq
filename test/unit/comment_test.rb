require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    Resque.reset!
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
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
    @comment.reload
    assert_not_nil @comment.notification_sent_at
  end
  
  # -------------------
  # should not send
  
  test "should NOT send notification if DISABLED for user" do
    @owner    = Factory(:user, :send_notifications => false)
    @deal     = Factory(:deal, :user => @owner)
    @comment  = Factory(:comment, :deal => @deal)
    
    Mailer.expects(:deal_commented).never

    Resque.run!
    @comment.reload
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
   
   test "should create a 'comment' event on creation" do
     @owner = Factory(:user)
     @commenter = Factory(:user)
     @deal = Factory(:deal, :user => @owner)
     @comment = Factory(:comment, :user => @commenter, :deal => @deal)
  
     assert_equal 1, @owner.events.size
     assert_equal "comment", @owner.events[0].event_type
     assert_equal @comment.body, @owner.events[0].metadata[:body]
     assert_equal @commenter, @owner.events[0].created_by
     assert_equal @deal, @owner.events[0].deal
   end
  
   test "should find mentioned users" do
     @mentionee = Factory(:user)
     @comment = Factory(:comment, :body => "Hi @#{@mentionee.username}!")
     assert_equal [ @mentionee ], @comment.mentioned_users
   end
  
   test "should create 'mention' events for mentioned users" do
     @owner = Factory(:user)
     @commenter = Factory(:user)
     @mentionee = Factory(:user)
     @deal = Factory(:deal, :user => @owner)
     @comment = Factory(:comment, :user => @commenter, :deal => @deal, :body => "Hi @#{@mentionee.username}!")
  
     assert_equal 1, @owner.events.size
     assert_equal 1, @mentionee.events.size
     assert_equal "mention", @mentionee.events[0].event_type
     assert_equal @comment.body, @mentionee.events[0].metadata[:body]
     assert_equal @commenter, @mentionee.events[0].created_by
     assert_equal @deal, @mentionee.events[0].deal
   end
 
end
