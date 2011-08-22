require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  
  def teardown
    Resque.reset!
  end
  
  
  # ---------
  # email notifcations 
  
  test "sends follower email notification" do
    @target = Factory(:user, :send_notifications => true)
    @user = Factory(:user)
    Mailer.expects(:new_follower).once.with(@target, @user).returns(mock(:deliver => true))
    
    Relationship.create(:user => @user, :target => @target)
  end
  
  test "sends friend email notification" do
    @target = Factory(:user, :send_notifications => true)
    @user = Factory(:user)
    
    User.any_instance.expects(:friends?).returns(true)
    Mailer.expects(:new_friend).once.with(@target, @user).returns(mock(:deliver => true))    
    
    Relationship.create(:user => @user, :target => @target)
  end
  
  test "should not send follower email notification" do
    @target = Factory(:user, :send_notifications => false)
    @user = Factory(:user)
    
    Mailer.expects(:new_follower).never
    
    Relationship.create(:user => @user, :target => @target)
  end
  
  
  test "updates follower and following counts when created" do
    @user = Factory(:user)
    @target = Factory(:user)

    Relationship.create(:user => @user, :target => @target)

    @user.reload
    @target.reload

    assert_equal 1, @user.following_count
    assert_equal 1, @target.followers_count
  end

  test "updates friend counts when created" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)

    Relationship.create(:user => @user0, :target => @user1)
    Relationship.create(:user => @user1, :target => @user0)

    @user0.reload
    @user1.reload

    assert_equal 1, @user0.friends_count
    assert_equal 1, @user1.friends_count
  end
  
  test "updates follower and following counts when destroyed" do
    @user = Factory(:user)
    @target = Factory(:user)

    @relationship = Relationship.create(:user => @user, :target => @target)

    @user.reload
    @target.reload

    assert_equal 1, @user.following_count
    assert_equal 1, @target.followers_count

    @relationship.destroy

    @user.reload
    @target.reload

    assert_equal 0, @user.following_count
    assert_equal 0, @target.followers_count
  end

  test "updates friend counts when destroyed" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)

    @relationship = Relationship.create(:user => @user0, :target => @user1)
    Relationship.create(:user => @user1, :target => @user0)

    @user0.reload
    @user1.reload

    assert_equal 1, @user0.friends_count
    assert_equal 1, @user1.friends_count

    @relationship.destroy

    @user0.reload
    @user1.reload

    assert_equal 0, @user0.friends_count
    assert_equal 0, @user1.friends_count
  end
end

