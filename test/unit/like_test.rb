require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  
  test "should send notification if enabled for user" do
    @owner  = Factory(:user, :send_notifications => true)
    @deal   = Factory(:deal, :user => @owner)
    @liker  = Factory(:user)
    @like   = Like.new(:user => @liker, :deal => @deal)
    
    Mailer.expects(:deal_liked).once.with(@owner, @like).returns(mock(:deliver => true))
    @like.save
  end
  
  test "should NOT send notification if DISABLED for user" do
    @owner  = Factory(:user, :send_notifications => false)
    @deal   = Factory(:deal, :user => @owner)
    @liker  = Factory(:user)

    Mailer.expects(:deal_liked).never
    Like.create(:user => @liker, :deal => @deal)
  end

end
