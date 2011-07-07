require 'test_helper'

class Api::SharesControllerTest < ActionController::TestCase
  test "should route to shares#create" do
    assert_routing({ :method => "post", :path => "/api/users/1/deals/2/shares.json" }, { 
      :format => "json", 
      :controller => "api/shares", 
      :action => "create",
      :deal_id => "2",
      :user_id => "1" })
  end

  test "should share a deal to multiple services on creation" do
    @user = Factory(:user)
    @deal = Factory(:deal, :user => @user)
    sign_in(@user)

    Qwiqq::Facebook.expects(:share_deal).once.with(@deal)
    Qwiqq::Twitter.expects(:share_deal).once.with(@deal)
    Mailer.expects(:share_deal).once.with(@deal, "eoin@gastownlabs.com").returns(mock(:deliver => true))
    Mailer.expects(:share_deal).once.with(@deal, "adam@gastownlabs.com").returns(mock(:deliver => true))

    post :create,
      :user_id => "current",
      :deal_id => @deal.id,
      :facebook => true,
      :twitter => true,
      :emails => [ "eoin@gastownlabs.com", "adam@gastownlabs.com" ],
      :format => "json"

    assert_equal 200, @response.status
    assert_equal 4, @user.shares.count
    assert_equal 1, @user.shared_deals.count
  end
end

