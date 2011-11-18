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
    
    # queues
    assert_equal 200, @response.status
    assert_equal 1, @deal.shares.count
    assert_equal 'twitter', @deal.shares.first.service
  end

  test "should share a deal on facebook" do
    @owner  = Factory(:user)
    @sharer = Factory(:user)
    @deal   = Factory(:deal, :user => @owner)
    sign_in(@sharer)
    
    # facebook shares are delvered immediately
    Share.any_instance.expects(:deliver_to_facebook).once

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
  end

  test "should share a deal to multiple services" do
    @owner  = Factory(:user)
    @sharer = Factory(:user)
    @deal   = Factory(:deal, :user => @owner)
    sign_in(@sharer)

    # facebook shares are delvered immediately
    Share.any_instance.expects(:deliver_to_facebook).once
    
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

  test "should handle when sharing to facebook fails due to an invalid access token" do
    @user = Factory(:user)
    @deal = Factory(:deal, :user => @user)
    sign_in(@user)
    
    # facebook shares are delvered immediately
    Share.any_instance.expects(:deliver_to_facebook).once.raises(Koala::Facebook::APIError.new({
      "type" => "OAuthException", 
      "message" => "Error validating access token: The session has been invalidated because the user has changed the password." }))

    post :create,
       :user_id => "current",
       :deal_id => @deal.id,
       :facebook => true,
       :twitter => true,
       :format => "json"

    @deal.reload
    assert_equal 422, @response.status
    assert_equal 1, @deal.shares.size 
    assert_equal 'twitter', @deal.shares.first.service
  end 

end

