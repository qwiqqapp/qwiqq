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
    @deal1 = Factory(:deal_at_gastownlabs, :name => 'used mac mini',    :likes_count => 5, :comments_count => 2, :category => @category, :created_at => Time.now - 30.minutes)
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
  
  test "should return user for valid username search" do   
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
  
  # ----------
  # category search
  
  test "should return two deals in category tech" do
    create_geo_deals
    @tech_deal = Factory(:deal, :category => Factory(:category, :name => 'tech'))    
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => 'tech', :format => "json"
      
      assert_equal Array,           json_response.class
      assert_equal 1,               json_response.size
      assert_equal @tech_deal.name, json_response.first['name']
    end
  end
  
  
  test "should return food deals in geo order" do
    create_geo_deals
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => 'food', :lat => @lat, :long => @lon, :format => "json"
      
      assert_equal Array,       json_response.class
      assert_equal 3,           json_response.size           #dont include seattle deal
      assert_equal @deal1.name, json_response[0]['name']     #gastownlabs deal should be first
      assert_equal @deal3.name, json_response[1]['name']     #sixacres deal should be 2nd
      assert_equal @deal2.name, json_response[2]['name']     #thelocal deal should be 3rd
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
  
  # ------------
  # filtered search
  
  test "should raise exception if filter not provided" do
    assert_raise(ActionController::RoutingError) {
      get :deals, :q => 'beer', :format => "json"
    }
  end
  
  test "should provide error message if lat/long not provided for nearby search" do
    get :deals, :q => 'beer', :filter => 'nearby', :format => "json"
    assert_match /not allowed/i, json_response['message']
  end
  

  test "should return matching deals for newest query" do
    create_geo_deals
    ThinkingSphinx::Test.index

    ThinkingSphinx::Test.run do
      get :deals, :q => 'beer', :filter => 'newest', :format => "json"
      
      assert_equal Array,       json_response.class
      assert_equal 3,           json_response.size
      assert_equal @deal3.name, json_response.first['name']       
    end
  end
  
  
  test "should return matching deals for nearby query" do
    create_geo_deals
    ThinkingSphinx::Test.index

    ThinkingSphinx::Test.run do
      get :deals, :q => 'beer', :filter => 'nearby', :lat => @lat, :long => @lon, :format => "json"
      
      assert_equal Array,       json_response.class
      assert_equal 2,           json_response.size
      assert_equal @deal3.name, json_response.first['name']
    end
  end
  
  test "should return matching deals for popular query" do
    create_geo_deals
    ThinkingSphinx::Test.index

    ThinkingSphinx::Test.run do
      get :deals, :q => 'beer', :filter => 'popular', :format => "json"
      
      assert_equal Array,       json_response.class
      assert_equal 3,           json_response.size
      assert_equal @deal2.name, json_response.first['name']
    end
  end


end