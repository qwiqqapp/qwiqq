require 'test_helper'

class Api::LikesControllerTest < ActionController::TestCase

  test "should route to likes#index for deals" do
    assert_routing('/api/deals/1/likes.json', {:format => 'json', :controller => 'api/likes', :action => 'index', :deal_id => '1'})
  end
  
  test "should route to likes#index for users" do
    assert_routing('/api/users/1/likes.json', {:format => 'json', :controller => 'api/likes', :action => 'index', :user_id => '1'})
  end
  
  test "should route to likes#create" do
    assert_routing({:method => 'post', :path => '/api/deals/1/like.json'}, {:format => 'json', :controller => 'api/likes', :action => 'create', :deal_id => '1'})
  end
  
  test "should route to likes#destroy" do
    assert_routing({:method => 'delete', :path => '/api/deals/1/like.json'}, 
                   {:format => 'json', :controller => "api/likes", :action => "destroy", :deal_id => '1'})
  end

  test "should render all users who like a deal" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    sign_in(@user0)

    @deal = Factory(:deal)
    @deal.likes.create(:user => @user0, :created_at => Time.now - 1.hour)
    @deal.likes.create(:user => @user1, :created_at => Time.now - 2.hours)

    get :index, :deal_id => @deal.id, :format => "json"

    assert_equal 200, @response.status
    assert_equal 2, json_response.size
    assert_equal @user0.id.to_s, json_response.first['user_id']
  end
  
  test "should render all deals liked by a user" do
    @user = Factory(:user)
    sign_in(@user)
    
    @deal0 = Factory(:deal, :created_at => Time.now - 1.hour)
    @deal1 = Factory(:deal, :created_at => Time.now - 2.hours)
            
    @user.likes.create(:deal => @deal0)
    @user.likes.create(:deal => @deal1)

    get :index, :user_id => @user.id, :format => "json"
    
    assert_equal 200, @response.status
    assert_equal 2, json_response.size
    assert_equal @deal0.id.to_s, json_response.first['deal_id']
  end
  
  test "should create a like for the current user and specified deal" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    sign_in(@user)
    
    Deal.expects(:increment_counter).once.with(:like_count, @deal.id)
    post :create, :deal_id => @deal.id, :format => "json"

    assert_equal 201, @response.status
  end

  test "should destroy a like for the current user and specified deal" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    sign_in(@user)

    Deal.expects(:decrement_counter).once.with(:like_count, @deal.id)
    @like = @deal.likes.create(:user => @user)

    delete :destroy, :deal_id => @deal.id, :format => "json"

    assert_equal 200, @response.status
  end

end
