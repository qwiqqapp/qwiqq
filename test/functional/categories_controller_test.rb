require 'test_helper'

class Api::CategoriesControllerTest < ActionController::TestCase
  
  test "should route to categories#show" do
    assert_routing( '/api/categories/travel', 
                    {:controller => "api/categories", :action => "show", :name => 'travel', :format => 'json'})
  end
  
  test "should return deals for category" do
    @user = Factory(:user)
    sign_in(@user)
    
    @category = Factory(:category)
    Factory(:deal, :category => @category)
    Factory(:deal, :category => @category)
    Factory(:deal, :category => @category)
    
    get :show, :name => @category.name, :format => 'json'
    
    assert_equal 200,   @response.status
    assert_equal Array, json_response.class
    assert_equal 3,     json_response.size
  end

end