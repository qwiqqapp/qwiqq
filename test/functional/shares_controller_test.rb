require 'test_helper'

class Api::SharesControllerTest < ActionController::TestCase

  def setup
    stub_indextank
  end
    
  test "should route to shares#create" do
    assert_routing({ :method => "post", :path => "/api/users/1/deals/2/shares.json" }, { 
      :format => "json", 
      :controller => "api/shares", 
      :action => "create",
      :deal_id => "2",
      :user_id => "1" })
  end
  
  test "should share a deal on facebook" do
    @owner  = Factory(:user)
    @sharer = Factory(:user)
    @deal   = Factory(:deal, :user => @owner)
    sign_in(@sharer)
    
    post :create,
       :user_id => "current",
       :deal_id => @deal.id,
       :facebook => true,
       :format => "json"
    
    # queues
    assert_equal 200, @response.status
    assert_equal 'facebook', @deal.shares.first.service
  end
  
  
  test "should share a deal to multiple services" do
    @owner  = Factory(:user)
    @sharer = Factory(:user)
    @deal   = Factory(:deal, :user => @owner)
    sign_in(@sharer)
    
    post :create,
      :user_id => "current",
      :deal_id => @deal.id,
      :facebook => true,
      :twitter => true,
      :emails => [ "eoin@gastownlabs.com", "adam@gastownlabs.com" ],
      :format => "json"
  
    # records
    assert_equal 200, @response.status
    assert_equal 4, @sharer.shares.count
    assert_equal 1, @sharer.shared_deals.count
  end
  

end

