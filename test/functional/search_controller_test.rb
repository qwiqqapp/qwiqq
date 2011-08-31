require 'test_helper'

class Api::SearchControllerTest < ActionController::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
  end
  
  def geo_deals_setup
    @category = Factory(:category, :name => 'tech')
    
    @deal0 = Factory(:deal_at_seattle,      :category => @category)
    @deal1 = Factory(:deal_at_gastownlabs,  :category => @category)
    @deal2 = Factory(:deal_at_thelocal,     :category => @category)
    @deal3 = Factory(:deal_at_sixacres,     :category => @category)
    
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
    @category0 = Factory(:category, :name => 'tech')
    @category1 = Factory(:category, :name => 'food')
    
    @deal0 = Factory(:deal, :category => @category0)
    @deal1 = Factory(:deal, :category => @category0)
    @deal2 = Factory(:deal, :category => @category1)
    
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => 'tech', :format => "json"
      
      assert_equal Array,       json_response.class
      assert_equal 2,           json_response.size
      assert_equal @deal0.name, json_response.first['name']
    end
  end
  
  
  test "should return tech deals in geo order" do
    geo_deals_setup
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => 'tech', :lat => @lat, :long => @lon, :format => "json"
      
      assert_equal Array,       json_response.class
      assert_equal 3,           json_response.size           #dont include seattle deal
      assert_equal @deal1.name, json_response[0]['name']     #gastownlabs deal should be first
      assert_equal @deal3.name, json_response[1]['name']     #sixacres deal should be 2nd
      assert_equal @deal2.name, json_response[2]['name']     #thelocal deal should be 3rd
    end
  end
  
  test "should return score/distance for geo deals" do
    geo_deals_setup
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => 'tech', :lat => @lat, :long => @lon, :format => "json"
       
      assert_equal 0.11, json_response[0]['score'].round(2)     #gastownlabs deal should be first
      assert_equal 0.26, json_response[1]['score'].round(2)     #sixacres deal should be 2nd
      assert_equal 2.16, json_response[2]['score'].round(2)     #thelocal deal should be 3rd
    end
  end
  
end