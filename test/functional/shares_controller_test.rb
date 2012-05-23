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
    
  test "should share a deal on twitter" do
    @owner  = Factory(:user)
    @sharer = Factory(:user)
    @deal   = Factory(:deal, :user => @owner)
    sign_in(@sharer)
    
    post :create,
       :user_id => "current",
       :deal_id => @deal.id,
       :twitter => true,
       :format => "json"
       
    # share is pushed to worker
    Share.any_instance.expects(:deliver_to_twitter).never
    
    # queues
    assert_equal 200, @response.status
    assert_equal 1, @deal.shares.count
    assert_equal 'twitter', @deal.shares.first.service
  end

  test "should create facebook share (for page)" do
    @owner  = Factory(:user)
    @sharer = Factory(:user, :current_facebook_page_id => '3234592348234')
    @deal   = Factory(:deal, :user => @owner)
    sign_in(@sharer)
    
    # share is pushed to worker queue
    Share.any_instance.expects(:deliver_to_facebook).never
    
    post :create,
       :user_id => "current",
       :deal_id => @deal.id,
       :facebook => true,
       :message => "I found a thing on Qwiqq!",
       :format => "json"
    
    # queues
    assert_equal 200, @response.status
    assert_equal 1, @deal.shares.count
    assert_equal 'facebook', @deal.shares.first.service
    assert_equal 'I found a thing on Qwiqq!', @deal.shares.first.message
    assert_equal '3234592348234', @deal.shares.first.facebook_page_id
  end

  test "should share a deal to multiple services" do
    @owner  = Factory(:user)
    @sharer = Factory(:user)
    @deal   = Factory(:deal, :user => @owner)
    sign_in(@sharer)

    # shares are pushed to worker
    Share.any_instance.expects(:deliver_to_facebook).never
    
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

