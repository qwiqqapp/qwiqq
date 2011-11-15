require 'test_helper'

class UserEventTest < ActiveSupport::TestCase  
  self.use_transactional_fixtures = false
  
  setup do
    DatabaseCleaner.start
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
end

