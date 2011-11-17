require 'test_helper'

class Api::DealsControllerTest < ActionController::TestCase
  
  test "should route to deals#index" do
    assert_routing('/api/users/1/deals.json', {:format => 'json', :controller => 'api/deals', :action => 'index', :user_id => "1"})
  end

  test "should route to deals#show" do
    assert_routing('/api/deals/1.json', {:format => 'json', :controller => 'api/deals', :action => 'show', :id => '1'})
  end
  
  test "should route to deals#create" do
    assert_routing({:method => 'post', :path => '/api/deals.json'}, {:format => 'json', :controller => 'api/deals', :action => 'create'})
  end
 
  test "should routes to deals#destroy" do
    assert_routing({ :method => "delete", :path => "/api/deals/1.json" }, 
                   { :format => "json", :controller => "api/deals", :action => "destroy", :id => "1"})
  end
  
  test "should route to deals#events" do
    assert_routing("/api/deals/1/events.json", {
      :format => "json", :controller => "api/deals", :action => "events", :id => "1" })
  end
  
  # deals#index
  test "should render deals for the current user" do
    @user = Factory(:user)
    Factory(:deal)                    #public deal, different owner
    Factory(:deal, :user => @user)
    Factory(:deal, :user => @user)
    Factory(:deal, :user => @user)
    
    sign_in(@user)
    
    get :index, :format => 'json', :user_id => 'current'
    
    assert_equal 200,   @response.status
    assert_equal Array, json_response.class
    assert_equal 3,     json_response.size
  end
  
  # deals#feed
  test "should render a users deals feed" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    
    sign_in(@user0)

    @user0.follow!(@user1)
    @user1.follow!(@user2)
    @user0.follow!(@user2)

    # deals from users followed by current user
    feed_deals = [
      Factory(:deal, :user => @user1, :created_at => 2.minutes.ago),
      Factory(:deal, :user => @user2, :created_at => 3.minutes.ago),
      Factory(:deal, :user => @user2, :created_at => 4.minutes.ago),
      Factory(:deal, :user => @user1, :created_at => 5.minutes.ago) ]

    get :feed, :format => 'json'
    
    assert_equal 200,   @response.status
    assert_equal Array, json_response.class
    assert_equal 4,     json_response.size
    assert_equal 10,    Feedlet.count # user0 sees 4 deals, user1 sees 2 deals
    
    # check order
    assert_equal feed_deals.map(&:id), json_response.map{|d| d["deal_id"].to_i}
  end

  test "should see feed deals previously posted by a user after following" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)

    sign_in(@user0)
    Factory(:deal, :user => @user1, :created_at => 10.minutes.ago)

    @user0.follow!(@user1)
    
    get :feed, :format => 'json'
    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 1, json_response.size
  end
  
  test "should no longer see deals from a user after unfollowing" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)

    sign_in(@user0)
    @user0.follow!(@user1)
    @user0.follow!(@user2)

    @deal1 = Factory(:deal, :user => @user1, :created_at => 10.minutes.ago)
    Factory(:deal, :user => @user2, :created_at => 10.minutes.ago)

    @user0.unfollow!(@user2)

    get :feed, :format => 'json'
    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 1, json_response.size
  end
  
  # deals#create
  test "should create deal for user with price" do
    @user     = Factory(:user)
    @category = Factory(:category)
    sign_in(@user)
    
    @params = { :name           => 'rainbow unicorn tshirt',
                :price          => 899,                       #integer cents
                :category_name  => @category.name,
                :photo          => File.new("test/fixtures/products/#{rand(22)}.jpg"),
                :lat            => '49.282784',
                :lon            => '-123.109617' }

    post :create, :deal => @params, :format => 'json'
    
    assert_equal 201, @response.status
    assert_equal @params[:name], json_response['name']
    assert_equal @params[:lat], json_response['lat']
    assert_equal @params[:lon], json_response['lon']
  end
  
  # deals#create validation
  test "should NOT create deal from post missing name and price" do
    @user     = Factory(:user)
    @category = Factory(:category)
    sign_in(@user)
    
    @params = { :category_name  => @category.name,
                :photo          => File.new("test/fixtures/products/#{rand(22)}.jpg")}
    
    post :create, :deal => @params, :format => 'json'
    
    assert_equal 422, @response.status
    assert_match /required/i, json_response['name'].first
    assert_match /price/i, json_response['base'].first
  end
  
  # deals#create validation only name
  test "should NOT create deal from post missing category and price" do
    @user = Factory(:user)
    sign_in(@user)
    
    @params = {:name => 'bacon brand tshirt' }
    
    post :create, :deal => @params, :format => 'json'
    
    assert_equal 422, @response.status

    assert_match /required/i, json_response['category'].first
    assert_match /price/i, json_response['base'].first    
  end
  
  # deals#create validation empty strings
  test "should NOT create deal from post with empty strings" do
    @user = Factory(:user)
    sign_in(@user)
    
    @params = { :name => '', :category => '', :price => '', :photo => '' }

    post :create, :deal => @params, :format => 'json'
    
    assert_equal 422, @response.status
    
    assert_match /required/i, json_response['name'].first
    assert_match /required/i, json_response['category'].first
    assert_match /price/i,    json_response['base'].first
  end
  
  # deals#show
  test "should render deal details" do
    @user0 = Factory(:user)
    sign_in(@user0)
    
    @deal = Factory(:deal)
    @user1 = Factory(:user)
    @comment = Factory(:comment, :user => @user1, :deal => @deal)
    @like = @deal.likes.create(:user => @user0)
    
    get :show, :id => @deal.id, :format => 'json'
    
    assert_equal 200, @response.status
    assert_equal true, json_response['liked']
    assert_equal Array, json_response['comments'].class
    assert_equal Array, json_response['liked_by_users'].class
    assert_equal 1, json_response['comments'].size
    assert_equal 1, json_response['liked_by_users'].size
  end

  # deals#destroy
  test "should delete a deal that belongs to the current user" do
    @user = Factory(:user)
    @deal = Factory(:deal, :user => @user)
    sign_in(@user)

    delete :destroy, :id => @deal.id, :format => "json"

    assert_equal 200, @response.status
  end

  # deals#events
  test "should render a deals events" do
    @user = Factory(:user)
    @deal = Factory(:deal, :user => @user)

    @like = Factory(:like, :deal => @deal)
    @share = Factory(:share, :deal => @deal, :service => "twitter")
    @comment = Factory(:comment, :deal => @deal)

    @like.create_event
    @comment.create_event
    @share.create_event

    sign_in @user
    get :events, :id => @deal.id, :format => "json"

    assert_equal 200, @response.status
    assert_equal 3, json_response.size
  end

end

