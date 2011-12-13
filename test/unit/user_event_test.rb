require 'test_helper'

class UserEventTest < ActiveSupport::TestCase  
  self.use_transactional_fixtures = false
  
  setup do
    DatabaseCleaner.start
    
    PushDevice.any_instance.stubs(:register).returns(true)
    PushDevice.any_instance.stubs(:unregister).returns(true)
  end
  
  teardown do
    DatabaseCleaner.clean
  end

  test "should update cached attributes on save" do
    @owner = Factory(:user)
    @commenter = Factory(:user)
    @deal = Factory(:deal, :user => @owner)
    @comment = Factory(:comment, :user => @commenter, :deal => @deal)
    
    assert_equal @deal.name, @owner.events[0].deal_name
    assert_equal @commenter.username, @owner.events[0].created_by_username
    assert !@owner.events[0].created_by_photo.blank?
    assert !@owner.events[0].created_by_photo_2x.blank?
  end
  
  test "#as_json" do
    # TODO
  end
  
  test "should deliver push notification for push_devices" do
    @owner  = Factory(:user)
    @device = Factory(:push_device, :user => @owner)
    @liker  = Factory(:user)
    @deal   = Factory(:deal, :user => @owner)
    
    Urbanairship.expects(:push).once.returns(true)
    
    @event = Factory(:user_event, 
                      :event_type => "like", 
                      :deal => @deal,
                      :user => @owner,
                      :created_by => @liker)
                      
    assert_not_nil @event.push_notification_sent_at
  end
  
  test "should deliver push notification content" do
  end
end

