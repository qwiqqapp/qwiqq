require 'test_helper'

class Api::CommentsControllerTest < ActionController::TestCase

  test "should route to comments#index" do
    assert_routing("/api/deals/1/comments.json", {
      :format => "json", :controller => "api/comments", :action => "index", :deal_id => "1" })
  end
  
  test "should route to comments#create" do
    assert_routing({ :method => "post", :path => "/api/deals/1/comments.json" }, {
      :format => "json", :controller => "api/comments", :action => "create", :deal_id => "1" })
  end

  test "should render all comments for the specified deal" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    sign_in(@user)

    @comment0 = Factory(:comment, :deal => @deal, :user => @user)
    @comment1 = Factory(:comment, :deal => @deal, :user => @user)

    get :index, :deal_id => @deal.id, :format => "json"

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 2, json_response.size
  end

  test "should create a comment on a deal for the current user" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    sign_in(@user)

    params = { :body => "This is the best deal ever." }
    post :create, :deal_id => @deal.id, :comment => params, :format => "json"

    assert_equal 201, @response.status
  end

  test "should fail to create an invalid comment" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    sign_in(@user)

    post :create, :deal_id => @deal.id, :comment => {}, :format => "json"

    # TODO shouldn't an invalid entity result in a 422?
    assert_equal 400, @response.status
  end

end
