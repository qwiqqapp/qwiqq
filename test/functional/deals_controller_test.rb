require 'test_helper'

class Api::DealsControllerTest < ActionController::TestCase

  test "should route to deals#index" do
    assert_routing('/api/deals', {:controller => "api/deals", :action => "index"})
  end
  
  test "should route to deals#show" do
    assert_routing('/api/deals/1', {:controller => "api/deals", :action => "show", :id => '1'})
  end
  
  test "should route to deals#create" do
    assert_routing({:method => 'post', :path => '/api/deals'}, {:controller => 'api/deals', :action => 'create'})
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
    @user = Factory(:user, :deals => [Factory(:deal), Factory(:deal), Factory(:deal)])
    sign_in(@user)
    
    @public_deal = Factory(:deal)
    
    get :feed, :format => 'json'
    
    assert_equal 200,   @response.status
    assert_equal Array, json_response.class
    assert_equal 4,     json_response.size
  end
  
  
  # deals#create
  test "should create deal for user" do
    @user   = Factory(:user)
    sign_in(@user)
    
    @params = Factory.attributes_for(:deal, :category_id => Factory(:category).id)
    
    post :create, :deal => @params, :format => 'json'
    
    assert_equal 201, @response.status
  end
  

  # deals#show
  test "should render deal details" do
    @user = Factory(:user)
    sign_in(@user)
    
    @deal = Factory(:deal)
    get :show, :id => @deal.id, :format => 'json'
    assert_equal 200, @response.status
  end
  
  
  # deals#

end
