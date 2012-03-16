require "test_helper"

class Api::SearchControllerTest < ActionController::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
  end
  
  def create_geo_deals
    @category = Factory(:category, :name => "food")
    
    @deal0 = Factory(:deal_at_seattle,     :foursquare_venue_name => 'space needle',  :name => "space needle beer",:likes_count => 9, :comments_count => 4, :category => @category, :created_at => 1.days.ago)
    @deal1 = Factory(:deal_at_gastownlabs, :foursquare_venue_name => 'Gastown Labs',  :name => "half a sandwhich", :likes_count => 5, :comments_count => 2, :category => @category, :created_at => 30.minutes.ago)
    @deal2 = Factory(:deal_at_thelocal,    :foursquare_venue_name => 'The Local',     :name => "burger and beer",  :likes_count => 85, :comments_count => 21, :category => @category, :created_at => 10.minutes.ago)
    @deal3 = Factory(:deal_at_sixacres,    :foursquare_venue_name => 'Six Acres',     :name => "german beer",      :likes_count => 23, :comments_count => 8, :category => @category, :created_at => 5.minutes.ago)
    @deal4 = Factory(:deal_at_sixacres,    :foursquare_venue_name => 'Six Acres',     :name => "hungarian beer",   :likes_count => 23, :comments_count => 8, :category => @category, :created_at => 35.days.ago)
    
    # current location = centre of +victory+ square
    @lat = 49.282224
    @lon = -123.110111
  end
  
  test "should route to search#users" do
    assert_routing(
      {:method => "get", :path => "/api/search/users.json"}, 
      {:format => "json", :controller => "api/search", :action => "users"}
    )
  end
  
  test "should route to search#category" do
    assert_routing(
      {:method => "get", :path => "/api/search/categories/food/deals.json"}, 
      {:format => "json", :controller => "api/search", :action => "category", :name => "food"}
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
      get :users, :q => "mark", :format => "json"
      
      assert_equal Array,  json_response.class
      assert_equal 1,      json_response.size
      assert_equal "mark", json_response.first["user_name"]
    end
  end
    
  # should match start of string allowing for q=grand result=grand_master_funk
  test "should return matching results for partial username search" do
    %w(prince_edward prince_charles joe sarah tommy).each do |name|
      Factory(:user, :username => name)
    end
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :users, :q => "prince", :format => "json"
    
      assert_equal Array,           json_response.class
      assert_equal 2,               json_response.size
      assert_equal "prince_edward",  json_response[0]["user_name"] 
      assert_equal "prince_charles", json_response[1]["user_name"] 
    end
  end
  
  # ----------
  # category search
  
  test "should return array of deals for category search" do
    create_geo_deals
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => "food", :lat => @lat, :long => @lon, :range => 500_000, :format => "json"

      assert_equal Array, json_response.class
    end
  end
  
  
  test "should return 4 deals in category food" do
    create_geo_deals
    Factory(:deal, :category => Factory(:category, :name => "tech")) #should not appear in results
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => "food", :lat => @lat, :long => @lon, :range => 500_000, :format => "json"

      assert_equal 4, json_response.size
    end
  end
  
  
  test "should return food deals in geo order" do
    create_geo_deals
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => "food", :lat => @lat, :long => @lon, :range => 500_000, :format => "json"
      
      assert_equal @deal1.name, json_response[0]["name"]     #gastownlabs deal should be first
      assert_equal @deal3.name, json_response[1]["name"]     #sixacres deal should be 2nd
      assert_equal @deal2.name, json_response[2]["name"]     #thelocal deal should be 3rd
      assert_equal @deal0.name, json_response[3]["name"]     #seattle space needle
    end
  end
  
  test "should return score/distance for geo deals" do
    create_geo_deals
    ThinkingSphinx::Test.index
    
    ThinkingSphinx::Test.run do
      get :category, :name => "food", :lat => @lat, :long => @lon, :format => "json"
       
      assert_equal 0.11, json_response[0]["score"].round(2)     #gastownlabs deal should be first
      assert_equal 0.26, json_response[1]["score"].round(2)     #sixacres deal should be 2nd
      assert_equal 2.16, json_response[2]["score"].round(2)     #thelocal deal should be 3rd
    end
  end
  
  # TODO test stale deals using ThinkingSphinx
  test "should not return nil deals" do
    create_geo_deals
    
    name = "food"
    results = [@deal0, @deal1, nil, @deal3]
    Deal.expects(:filtered_search).returns(results)

    get :category, :name => name, :format => "json"
    
    assert_equal 3, json_response.size
    
    assert_not_nil json_response[0]
    assert_not_nil json_response[1]
    assert_not_nil json_response[2]
  end
  
  
  # ------------
  # filtered search

  test "should return matching deals for nearby query" do
    create_geo_deals
    ThinkingSphinx::Test.index

    ThinkingSphinx::Test.run do
      get :deals, :q => "beer", :lat => @lat, :long => @lon, :range => 500_000, :format => "json"
      
      assert_equal 3,           json_response.size
      assert_equal @deal3.name, json_response.first["name"]
    end
  end

  test "should return matching deals for venue name" do
    create_geo_deals

    ThinkingSphinx::Test.index
    ThinkingSphinx::Test.run do
      get :deals, :q => "labs", :lat => @lat, :long => @lon, :range => 500_000, :format => "json"
      assert_equal 1, json_response.size
      assert_equal @deal1.name, json_response.first["name"]
    end
  end
end
