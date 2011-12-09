require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    Resque.reset!
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
  end

  # ---------
  # email notifcations
  
  test "should queue relationship notification delivery" do
    @relationship = Factory(:relationship)
    
    assert_nil @relationship.notification_sent_at
    assert_queued(RelationshipNotifyJob, [@relationship.id])
  end
  
  test "should send new follower email notification if enabled for user" do
    @target = Factory(:user, :send_notifications => true)
    @user   = Factory(:user)
    Factory(:relationship, :user => @user, :target => @target)
    
    Mailer.expects(:new_follower).once.with(@target, @user).returns(mock(:deliver => true))
    Resque.run!
  end
  
  test "should update sent_at" do
    @target = Factory(:user, :send_notifications => true)    
    @relationship = Factory(:relationship, :target => @target)
    
    Resque.run!
    @relationship.reload
    assert_not_nil @relationship.notification_sent_at
  end
  
  test "should NOT raise exception for follow+unfollow and record not found" do
   @relationship = Factory(:relationship) 
    
    #user unfollows user    
    @relationship.destroy
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
        Resque.run!
    end
  end

  
  # -------
  # counts
  
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
    
    @user0.follow!(@user1)
    @user1.follow!(@user0)
    
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
    
    @user0.follow!(@user1)
    @user1.follow!(@user0)
    
    @user0.reload
    @user1.reload
    
    assert_equal 1, @user0.friends_count
    assert_equal 1, @user1.friends_count
    
    @user0.unfollow!(@user1)
    
    @user0.reload
    @user1.reload
    
    assert_equal 0, @user0.friends_count
    assert_equal 0, @user1.friends_count
  end

  test "creates a 'follower' event on creation" do
    @user = Factory(:user)
    @target = Factory(:user)
    @relationship = Factory(:relationship, :user => @user, :target => @target)

    assert_equal 1, @target.events.size
    assert_equal "follower", @target.events[0].event_type
  end
end

