require 'test_helper'

class Api::ConstantcontactControllerTest < ActionController::TestCase

   test "should route to constantcontact#index" do
    assert_routing("/api/users/1/constantcontact.json", {
      :format => "json", 
      :controller => "api/invitations", 
      :action => "index", 
      :user_id => "1"})
  end

  test "should render a constantcontact email" do
    @user = User.find_by_email("michaelscaria26@gmail.com")

    Mailer.constant_contact(@user).deliver

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 1, json_response.size 
  end
end
