require 'test_helper'

class Api::LikesControllerTest < ActionController::TestCase

  test "should route to likes#index" do
    assert_routing('/api/deals/1/likes.json', {:format => 'json', :controller => 'api/likes', :action => 'index', :deal_id => '1'})
  end
  
  test "should route to likes#create" do
    assert_routing({:method => 'post', :path => '/api/deals/1/likes.json'}, {:format => 'json', :controller => 'api/likes', :action => 'create', :deal_id => '1'})
  end

  test "should render all likes for a deal" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    sign_in(@user0)

    @deal = Factory(:deal)
    @deal.likes.create(:user => @user0)
    @deal.likes.create(:user => @user1)

    get :index, :deal_id => @deal.id, :format => "json"

    assert_equal 200, @response.status
    assert_equal 2, json_response.size
  end

  test "should create a like for the current user and specified deal" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    sign_in(@user)

    post :create, :deal_id => @deal.id, :format => "json"

    assert_equal 201, @response.status
  end

end
