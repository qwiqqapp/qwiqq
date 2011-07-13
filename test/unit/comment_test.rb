require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "strips body before saving" do
    @comment = Factory(:comment, :body => "        body      ")
    assert_equal "body", @comment.body
  end
end

