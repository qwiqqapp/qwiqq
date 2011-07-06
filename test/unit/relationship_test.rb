require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  test "updates follower and following counts on User" do
    @user = Factory(:user)
    @target = Factory(:user)

    Relationship.create(:user => @user, :target => @target)

    @user.reload
    @target.reload

    assert_equal 1, @user.following_count
    assert_equal 1, @target.followers_count
  end

  test "updates friend counts on User" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)

    Relationship.create(:user => @user0, :target => @user1)
    Relationship.create(:user => @user1, :target => @user0)

    @user0.reload
    @user1.reload

    assert_equal 1, @user0.followers_count
    assert_equal 1, @user0.following_count
    assert_equal 1, @user0.friends_count

    assert_equal 1, @user1.followers_count
    assert_equal 1, @user1.following_count
    assert_equal 1, @user1.friends_count
  end
end
