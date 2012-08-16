require 'test_helper'

class Api::InvitationsControllerTest < ActionController::TestCase
  test "should route to invitations#index" do
    assert_routing("/api/users/1/invitations.json", {
      :format => "json", 
      :controller => "api/invitations", 
      :action => "index", 
      :user_id => "1"})
  end

  test "should route to invitations#create" do
    assert_routing({ :method => "post", :path => "/api/users/1/invitations.json" }, { 
      :format => "json", 
      :controller => "api/invitations", 
      :action => "create",
      :user_id => "1" })
  end

  test "should render a users sent invitations" do
    @user = Factory(:user)
    sign_in(@user)

    Invitation.any_instance.stubs(:deliver!)
    Invitation.create(:user => @user, :service => "email", :email => "eoin@gastownlabs.com")

    get :index, :user_id => @user.id, :format => "json"

    assert_equal 200, @response.status
    assert_equal Array, json_response.class
    assert_equal 1, json_response.size 
  end
end
