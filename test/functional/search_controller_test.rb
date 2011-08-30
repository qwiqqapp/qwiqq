require 'test_helper'

class Api::SearchControllerTest < ActionController::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
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
  
  test "should return deals for a category" do
    @category0 = Factory(:category, :name => 'tech')
    @category1 = Factory(:category, :name => 'food')
    @category2 = Factory(:category, :name => 'sports')    
    
    @deal0 = Factory(:deal, :category => @category0)
    @deal1 = Factory(:deal, :category => @category1)
    @deal2 = Factory(:deal, :category => @category2)  
    @deal3 = Factory(:deal, :category => @category0)
    
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => 'tech', :format => "json"
      
      assert_equal Array,     json_response.class
      assert_equal 2,         json_response.size
      assert_equal @deal0.id, json_response.first['id']
    end
    
  end
  
  
  
  
  
  
end