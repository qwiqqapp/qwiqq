require 'test_helper'

class Api::SearchControllerTest < ActionController::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
  end
  
  def create_geo_deals
    @category = Factory(:category, :name => 'food')
    
    @deal0 = Factory(:deal_at_seattle,     :name => 'space needle beer',:likes_count => 9, :comments_count => 4, :category => @category, :created_at => Time.now - 1.days)
    @deal1 = Factory(:deal_at_gastownlabs, :name => 'half a sandwhich', :likes_count => 5, :comments_count => 2, :category => @category, :created_at => Time.now - 30.minutes)
    @deal2 = Factory(:deal_at_thelocal,    :name => 'burger and beer',  :likes_count => 85, :comments_count => 21, :category => @category, :created_at => Time.now - 10.minutes)
    @deal3 = Factory(:deal_at_sixacres,    :name => 'german beer',      :likes_count => 23, :comments_count => 8, :category => @category, :created_at => Time.now - 5.minutes)
    
    # current location = centre of +victory+ square
    @lat = 49.282224
    @lon = -123.110111
  end
  
  test "should route to search#deals" do
    assert_routing(
      {:method => 'get', :path => '/api/search/deals/nearby.json'}, 
      {:format => 'json', :controller => 'api/search', :action => 'deals', :filter => 'nearby'}
    )
  end
  
  test "should route to search#users" do
    assert_routing(
      {:method => 'get', :path => '/api/search/users.json'}, 
      {:format => 'json', :controller => 'api/search', :action => 'users'}
    )
  end
  
  test 'should route to search#category' do
    assert_routing(
      {:method => 'get', :path => '/api/search/categories/food/deals.json'}, 
      {:format => 'json', :controller => 'api/search', :action => 'category', :name => 'food'}
    )
  end
  
  #  ------------
  #  users
  
  test "should return matching result for full username search" do   
    %w(john jack mark peter mary).each do |name|
      Factory(:user, :username => name)
    end
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :users, :q => 'mark', :format => "json"
      
      assert_equal Array,  json_response.class
      assert_equal 1,      json_response.size
      assert_equal 'mark', json_response.first['user_name']
    end
  end
    
  # should match start of string allowing for q=grand result=grand_master_funk
  test "should return matching results for partial username search" do
    %w(prince_edward prince_charles joe sarah tommy).each do |name|
      Factory(:user, :username => name)
    end
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :users, :q => 'prince', :format => "json"
    
      assert_equal Array,           json_response.class
      assert_equal 2,               json_response.size
      assert_equal 'prince_edward',  json_response[0]['user_name'] 
      assert_equal 'prince_charles', json_response[1]['user_name'] 
  end
  end
  
  # ----------
  # category search
  
  test "should return array of deals for category search" do
    create_geo_deals
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => 'food', :format => "json"
      assert_equal Array, json_response.class
    end
  end
  
  
  test "should return 4 deals in category food" do
    create_geo_deals
    Factory(:deal, :category => Factory(:category, :name => 'tech')) #should not appear in results    
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => 'food', :format => "json"

      assert_equal 4,           json_response.size
      assert_equal @deal0.name, json_response.first['name']
    end
  end
  
  
  test "should return food deals in geo order" do
    create_geo_deals
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => 'food', :lat => @lat, :long => @lon, :format => "json"
      
      assert_equal @deal1.name, json_response[0]['name']     #gastownlabs deal should be first
      assert_equal @deal3.name, json_response[1]['name']     #sixacres deal should be 2nd
      assert_equal @deal2.name, json_response[2]['name']     #thelocal deal should be 3rd
      assert_equal @deal0.name, json_response[3]['name']     #seattle space needle
    end
  end
  
  test "should return score/distance for geo deals" do
    create_geo_deals
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => 'food', :lat => @lat, :long => @lon, :format => "json"
       
      assert_equal 0.11, json_response[0]['score'].round(2)     #gastownlabs deal should be first
      assert_equal 0.26, json_response[1]['score'].round(2)     #sixacres deal should be 2nd
      assert_equal 2.16, json_response[2]['score'].round(2)     #thelocal deal should be 3rd
    end
  end
  
  # TODO test stale deals using ThinkingSphinx
  test "should not return nil deals" do
    create_geo_deals
    
    name    = 'food'
    results = [@deal0, @deal1, nil, @deal3]
    opts    = {:conditions => {:category => name}, :order => "@relevance DESC"}
    Deal.expects(:search).with(opts).returns(results)

    get :category, :name => name, :format => "json"
    
    assert_equal 3, json_response.size
    
    assert_not_nil json_response[0]
    assert_not_nil json_response[1]
    assert_not_nil json_response[2]
  end
  
  
  
  # ------------
  # filtered search
  
  test "should raise exception if filter not provided" do
    assert_raise(ActionController::RoutingError) {
      get :deals, :q => 'beer', :format => "json"
    }
  end
  
  test "should NOT raise exception for empty query" do
    assert_nothing_raised do
      get :deals, :q => ' ', :filter => 'popular', :format => "json"
    end
    assert_equal [], json_response
  end
  
  test "should provide error message if lat/long not provided for nearby search" do
    get :deals, :q => 'beer', :filter => 'nearby', :format => "json"
    assert_match /not allowed/i, json_response['message']
  end
  
  test "should return array of deals for search/newest" do
    create_geo_deals
    ThinkingSphinx::Test.index

    ThinkingSphinx::Test.run do
      get :deals, :q => 'beer', :filter => 'newest', :format => "json"
      assert_equal Array, json_response.class
      assert_equal 3,           json_response.size
      assert_equal @deal3.name, json_response.first['name']       
    end
  end
  

  test "should return matching deals for newest query" do
    create_geo_deals
    ThinkingSphinx::Test.index

    ThinkingSphinx::Test.run do
      get :deals, :q => 'beer', :filter => 'newest', :format => "json"
      
      assert_equal 3,           json_response.size
      assert_equal @deal3.name, json_response.first['name']       
    end
  end
  
  
  test "should return matching deals for nearby query" do
    create_geo_deals
    ThinkingSphinx::Test.index

    ThinkingSphinx::Test.run do
      get :deals, :q => 'beer', :filter => 'nearby', :lat => @lat, :long => @lon, :format => "json"
      
      assert_equal 3,           json_response.size
      assert_equal @deal3.name, json_response.first['name']
    end
  end
  
  test "should return matching deals for popular query" do
    create_geo_deals
    ThinkingSphinx::Test.index

    ThinkingSphinx::Test.run do
      get :deals, :q => 'beer', :filter => 'popular', :format => "json"
      

      assert_equal 3,           json_response.size
      assert_equal @deal2.name, json_response.first['name']
    end
  end
end
