require 'test_helper'

class Api::SearchControllerTest < ActionController::TestCase

  setup do
    stub_indextank
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
    get :users, :q => 'mark', :format => "json"
    
    assert_equal Array,  json_response.class
    assert_equal 1,      json_response.size
    assert_equal 'mark', json_response.first['user_name']
  end
  
  
  test "should call indextank and request newest" do
    results = [{:deal_id => 34, :name => 'carson', :image => 'http://url.com/image.jpg'},
               {:deal_id => 31, :name => 'cars',    :image => 'http://url.com/image2.jpg'}]    

    Qwiqq::Indextank::Document.expects(:search).with('car', 'newest', {:lat => nil, :long => nil}).returns(results)
    
    get :deals, :q => 'car', :filter => 'newest', :format => 'json'
    
    assert_equal Array, json_response.class
    assert_equal 2,     json_response.size
  end
  
  
  test "should render deals for food category" do
    results = [{:deal_id => 34, :name => 'carson', :image => 'http://url.com/image.jpg'},
               {:deal_id => 31, :name => 'cars', :image => 'http://url.com/image2.jpg'}]
    
    Qwiqq::Indextank::Document.expects(:search).with('food', 'category', {:lat => nil, :long => nil}).returns(results)
    
    get :category, :name => 'food', :format => 'json'
    
    assert_equal Array, json_response.class
    assert_equal 2,     json_response.size    
  end

end