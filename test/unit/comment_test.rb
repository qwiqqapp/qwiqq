require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  
  setup do
    stub_indextank
  end
  
  test "strips body before saving" do
    @comment = Factory(:comment, :body => "        body      ")
    assert_equal "body", @comment.body
  end
  
  test "should send notification if enabled for user" do
    @owner      = Factory(:user, :send_notifications => true)
    @deal       = Factory(:deal, :user => @owner)
    @comment    = Comment.new(:user => Factory(:user), :deal => @deal, :body => 'awesome!!')
    
    Mailer.expects(:deal_commented).once.with(@owner, @comment).returns(mock(:deliver => true))
    @comment.save
  end
  
  test "should NOT send notification if DISABLED for user" do
    @owner  = Factory(:user, :send_notifications => false)
    @deal   = Factory(:deal, :user => @owner)

    Mailer.expects(:deal_commented).never
    Comment.new(:user => Factory(:user), :deal => @deal, :body => 'awesome!!')
  end
end
