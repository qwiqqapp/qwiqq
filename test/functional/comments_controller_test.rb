require 'test_helper'

class Api::CommentsControllerTest < ActionController::TestCase

  test "should route to comments#index for deals" do
    assert_routing("/api/deals/1/comments.json", {
      :format => "json", :controller => "api/comments", :action => "index", :deal_id => "1" })
  end
  
  test "should route to comments#index for users" do
    assert_routing("/api/users/1/comments.json", {
      :format => "json", :controller => "api/comments", :action => "index", :user_id => "1" })
  end
  
  test "should route to comments#create" do
    assert_routing({ :method => "post", :path => "/api/deals/1/comments.json" }, {
      :format => "json", :controller => "api/comments", :action => "create", :deal_id => "1" })
  end

  test "should routes to comments#destroy" do
    assert_routing({ :method => "delete", :path => "/api/comments/1.json" }, {
      :format => "json", :controller => "api/comments", :action => "destroy", :id => "1"})
  end
  
  test "should return comments for a deal" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    sign_in(@user)
    
    @comment0 = Factory(:comment, :deal => @deal, :user => @user, :created_at => Time.now - 1.hour)
    @comment1 = Factory(:comment, :deal => @deal, :user => @user, :created_at => Time.now - 2.hours)
    
    get :index, :deal_id => @deal.id, :format => "json"
    
    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 2, json_response.size
    
    # content
    assert_equal @comment0.id.to_s, json_response.first['comment_id']
    assert_equal @user.id.to_s, json_response.first['user']['user_id']
  end
  
  test "should return comments from a user" do
    @user = Factory(:user)
    sign_in(@user)
    
    @deal0 = Factory(:deal)
    @deal1 = Factory(:deal)

    @comment0 = Factory(:comment, :deal => @deal0, :user => @user, :created_at => Time.now - 1.hour)
    @comment1 = Factory(:comment, :deal => @deal1, :user => @user, :created_at => Time.now - 2.hours)

    get :index, :user_id => @user.id, :format => "json"
    
    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 2, json_response.size
    
    # content
    assert_equal @comment0.id.to_s, json_response.first['comment_id']
  end

  test "should return comments from the current user" do
    @user = Factory(:user)
    sign_in(@user)
    
    @deal0 = Factory(:deal)
    @deal1 = Factory(:deal)

    @comment0 = Factory(:comment, :deal => @deal0, :user => @user, :created_at => Time.now - 1.hour)
    @comment1 = Factory(:comment, :deal => @deal1, :user => @user, :created_at => Time.now - 2.hours)

    get :index, :user_id => "current", :format => "json"
    
    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 2, json_response.size
    
    # content
    assert_equal @comment0.id.to_s, json_response.first['comment_id']
  end

  test "should create a comment on a deal for the current user" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    sign_in(@user)

    params = { :body => "This is the best deal ever." }

    Deal.expects(:increment_counter).once.with(:comment_count, @deal.id)
    post :create, :deal_id => @deal.id, :comment => params, :format => "json"

    assert_equal 201, @response.status
    Deal.unstub(:increment_counter)
  end

  test "should fail to create an invalid comment" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    sign_in(@user)

    Deal.expects(:increment_counter).never
    post :create, :deal_id => @deal.id, :comment => {}, :format => "json"

    # TODO shouldn't an invalid entity result in a 422?
    assert_equal 400, @response.status
    Deal.unstub(:increment_counter)
  end

  test "should delete a comment if it belongs to the current user" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    @comment = Factory(:comment, :user => @user, :deal => @deal)
    sign_in(@user)

    delete :destroy, :id => @comment.id, :format => "json"

    assert_equal 200, @response.status
  end
  
end
