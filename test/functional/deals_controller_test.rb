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
  
  test "should route to deals#repost" do
    assert_routing({:method => 'post', :path => '/api/deals/1/repost.json'}, {:format => 'json', :controller => 'api/deals', :action => 'repost', :id => '1' })
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

    # deals from users followed by current user
    feed_deals = [
      Factory(:deal, :user => @user1, :created_at => 1.minutes.ago),
      Factory(:deal, :user => @user2, :created_at => 40.minutes.ago),
      Factory(:deal, :user => @user2, :created_at => 2.hours.ago),
      Factory(:deal, :user => @user1, :created_at => 3.days.ago) ]

    @user0.follow!(@user1)
    @user0.follow!(@user2)

    get :feed, :format => 'json'
    
    assert_equal 200,   @response.status
    assert_equal Array, json_response.class
    assert_equal 4,     json_response.size
    
    # check order
    assert_equal feed_deals.map(&:id), json_response.map{|d| d["deal_id"].to_i}
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

    # mock Deal#geodecode_location_name
    location_name = 'Comox Street, Vancouver'
    lat, lon = @params[:lat].to_f, @params[:lon].to_f

    Deal.expects(:geodecode_location_name).with(lat, lon).returns(location_name)
    Qwiqq::Indextank::Document.any_instance.expects(:add).once
    
    
    post :create, :deal => @params, :format => 'json'
    
    assert_equal 201, @response.status
    assert_equal @params[:name], json_response['name']
    assert_equal @params[:lat], json_response['lat']
    assert_equal @params[:lon], json_response['lon']
    assert_equal location_name, json_response['location_name']
  end
  
  # deals#create validation
  test "should NOT create deal from post missing name and price" do
    @user     = Factory(:user)
    @category = Factory(:category)
    sign_in(@user)
    
    @params = { :category_name  => @category.name,
                :photo          => File.new("test/fixtures/products/#{rand(22)}.jpg")}
    
    
    # should not update indextank
    Qwiqq::Indextank::Document.any_instance.expects(:add).never
        
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
    Qwiqq::Indextank::Document.any_instance.expects(:add).never
    
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
    Qwiqq::Indextank::Document.any_instance.expects(:add).never  
    
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

  # deals#repost
  test "should allow a deal to be reposted" do
    @user = Factory(:user)
    @deal = Factory(:deal)
    sign_in(@user)
    
    post :repost, :id => @deal.id, :user_id => @user.id, :format => "json"

    assert_equal 201, @response.status
    assert_equal 1, @user.reposted_deals.count
  end
  
end

