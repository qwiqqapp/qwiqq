require 'test_helper'

class Api::ConstantcontactControllerTest < ActionController::TestCase

   test "should route to transaction#index" do
    assert_routing("/api/deals/1/transaction.json", {
      :format => "json", 
      :controller => "api/invitations", 
      :action => "index", 
      :user_id => "1"})
  end

end