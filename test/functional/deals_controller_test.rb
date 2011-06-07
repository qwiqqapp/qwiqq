require 'test_helper'

class Api::DealsControllerTest < ActionController::TestCase

  test "should route to deals#index" do
    assert_routing('/api/deals.json', {:format => 'json', :controller => "api/deals", :action => "index"})
  end
  
  test "should route to deals#show" do
    assert_routing('/api/deals/1.json', {:format => 'json', :controller => "api/deals", :action => "show", :id => '1'})
  end
  
  test "should route to deals#create" do
    assert_routing({:method => 'post', :path => '/api/deals.json'}, {:format => 'json', :controller => 'api/deals', :action => 'create'})
  end

  test "should route to deals#search" do
    assert_routing({:method => 'get', :path => '/api/search.json'}, {:format => 'json', :controller => 'api/deals', :action => 'search'})
  end
  
  # deals#index
  test "should render current_user deals" do
    @user = Factory(:user, :deals => [Factory(:deal), Factory(:deal)])
    sign_in(@user)
    @public_deal = Factory(:deal)
    
    get :index, :format => 'json'
    
    assert_equal 200,   @response.status
    assert_equal Array, json_response.class
    assert_equal 2,     json_response.size
  end
  
  # deals#feed
  test "should render recent public deals" do
    @user = Factory(:user)
    @deals =  [  Factory(:deal, :premium => false, :created_at => Time.now - 1.days, :user => @user),
                 Factory(:deal, :premium => true,  :created_at => Time.now - 2.days),    #should be first
                 Factory(:deal, :premium => false, :created_at => Time.now - 3.days)]
    
    sign_in(@user)
    
    get :feed, :format => 'json'
    
    assert_equal 200,   @response.status
    assert_equal Array, json_response.class
    assert_equal 3,     json_response.size
    
    # check premium order
    assert_equal [true, false, false],  json_response.map{|d| d['premium']}
  end
  
  # deals#popular
  
  
  # deals#create
  test "should create deal for user with price" do
    @user   = Factory(:user)
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
  
  # deals#show
  test "should render deal details" do
    @user = Factory(:user)
    sign_in(@user)
    @deal = Factory(:deal)
    
    get :show, :id => @deal.id, :format => 'json'
    assert_equal 200, @response.status
  end

  # deals#search
  test "should render deals with names matched by query" do
    @user = Factory(:user)
    sign_in(@user)

    @deals =  [ 
      Factory(:deal, :name => "iPod"),
      Factory(:deal, :name => "High Heels"),
      Factory(:deal, :name => "Red High Heels") ]

    get "search", :q => "High Heels", :format => "json"

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 2, json_response.size
  end

  test "should render an empty array when query matches no deals" do
    @user = Factory(:user)
    sign_in(@user)

    @deals =  [ 
      Factory(:deal, :name => "iPod"),
      Factory(:deal, :name => "High Heels"),
      Factory(:deal, :name => "Red High Heels") ]

    get "search", :q => "Bacon", :format => "json"

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 0, json_response.size
  end
end

