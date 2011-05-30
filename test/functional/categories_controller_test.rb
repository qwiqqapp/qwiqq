require 'test_helper'

class Api::CategoriesControllerTest < ActionController::TestCase
  
  test "should route to categories#show" do
    assert_routing('/api/categories/travel', {:controller => "api/categories", :action => "show", :name => 'travel'})
  end
  
  # test "should return deals for category" do
  #   @user = Factory(:user)
  #   sign_in(@user)
  #   
  #   @category = Factory(:category, :deals => [Factory(:deal), Factory(:deal)])
  #   
  #   get :show, :name => @category.name, :format => 'json'
  #   
  #   assert_equal 200, @response.status
  #   assert_equal Array, json_response.class
  #   assert_equal @category.deals.size, json_response.size
  # end
end