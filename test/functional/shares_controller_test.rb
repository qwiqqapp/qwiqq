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
    @owner = Factory(:user)
    @sharer = Factory(:user)
    @deal = Factory(:deal, :user => @owner)
    sign_in(@sharer)

    User.any_instance.expects(:share_deal_to_twitter).once.with(@deal)
    User.any_instance.expects(:share_deal_to_facebook).once.with(@deal)
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
    assert_equal 4, @sharer.shares.count
    assert_equal 1, @sharer.shared_deals.count
  end
end

