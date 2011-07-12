require 'test_helper'

class Api::SearchControllerTest < ActionController::TestCase

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

  # test "should route to search#users" do
  #   assert_routing('/api/categories/travel/deals', 
  #                  {:controller => 'api/deals', :action => 'category', :name => 'travel', :format => 'json'})
  # end


  # deals#search
  # test "should render deals with names matched by query" do
  #   @user = Factory(:user)
  #   sign_in(@user)
  # 
  #   @deals =  [ 
  #     Factory(:deal, :name => "iPod"),
  #     Factory(:deal, :name => "High Heels"),
  #     Factory(:deal, :name => "Red High Heels") ]
  # 
  #   get :search, :q => "high heels", :format => "json"
  # 
  #   assert_equal 200, @response.status
  #   assert_equal Array, json_response.class
  #   assert_equal 2, json_response.size
  # end
  
  # deals#category
  # test "should return deals for category" do
  #   @user = Factory(:user)
  #   sign_in(@user)
  #   
  #   @category = Factory(:category)
  #   Factory(:deal, :category => @category)
  #   Factory(:deal, :category => @category)
  #   Factory(:deal, :category => @category)
  #   
  #   get :category, :name => @category.name, :format => "json"
  #   
  #   assert_equal 200,   @response.status
  #   assert_equal Array, json_response.class
  #   assert_equal 3,     json_response.size
  # end
  
  
  # test "should render an empty array when query matches no deals" do
  #   @user = Factory(:user)
  #   sign_in(@user)
  #   
  #   @deals =  [ 
  #     Factory(:deal, :name => "iPod"),
  #     Factory(:deal, :name => "High Heels"),
  #     Factory(:deal, :name => "Red High Heels") ]
  # 
  #   get :search, :q => "Bacon", :format => "json"
  # 
  #   assert_equal 200, @response.status
  #   assert_equal Array, json_response.class
  #   assert_equal 0, json_response.size
  # end

end