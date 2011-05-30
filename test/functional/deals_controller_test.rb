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
  
  
  test "should render deals" do
    @deals = [Factory(:deal), Factory(:deal), Factory(:deal)]
    get :index, :format => 'json'
    
    assert_equal 200,   @response.status
    assert_equal Array, json_response.class
    assert_equal 3,     json_response.size
  end

  test "should render deal details" do
    @deal = Factory(:deal)
    get :show, :id => @deal.id, :format => 'json'
    
    assert_equal 200, @response.status
  end

  test "should create deal from valid hash" do
    @user   = Factory(:user)
    @params = Factory.attributes_for(:deal, :category_id => Factory(:category).id)
    sign_in(@user)
    
    post :create, :deal => @params, :format => 'json'
    
    assert_equal 201, @response.status
  end
end
