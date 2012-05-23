require 'test_helper'

class CouponsControllerTest < ActionController::TestCase
  test "routes to coupons#show for deals" do
    assert_routing("/posts/1/coupon", { :controller => "coupons", :action => "show", :deal_id => "1" })
  end

  test "redeems and shows the coupon for a deal with remaining coupons" do
    deal = Factory(:deal, :coupon => true, :coupon_count => 10)
    get :show, :deal_id => deal.id
    deal.reload
    assert_equal 9, deal.coupon_count
  end
end
