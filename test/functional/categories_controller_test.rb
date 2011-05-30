require 'test_helper'

class Api::CategoriesControllerTest < ActionController::TestCase
  
  test "should route to categories#index" do
    assert_routing('/api/categories', {:controller => "api/categories", :action => "index"})
  end
  
  test "should route to categories#show" do
    assert_routing('/api/categories/1', {:controller => "api/categories", :action => "show", :id => '1'})
  end
  

  test "should return categories" do
    @user = Factory(:user)
    sign_in(@user)
    
    @categories = [Factory(:category),Factory(:category),Factory(:category),Factory(:category)]
    
    get :index, :format => 'json'
    
    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal @categories.size, json_response.size
  end
  
  
  test "should return deals for category" do
    @user = Factory(:user)
    sign_in(@user)
    
    @category = Factory(:category, :deals => [Factory(:deal), Factory(:deal)])
    @categoryB = Factory(:category, :deals => [Factory(:deal)])
    
    get :show, :id => @category.id, :format => 'json'
    
    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal @category.deals.size, json_response.size
  end
end  