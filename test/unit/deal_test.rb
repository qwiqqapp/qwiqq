require 'test_helper'

class DealTest < ActiveSupport::TestCase

  self.use_transactional_fixtures = false
  
  setup do
    Resque.reset!
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
  end
  
  # --------------
  #  validation
  
  test "valid deal" do
    assert_nothing_raised do
      @deal = Factory(:deal, :name => 'deal name here')
    end
    assert_equal true, @deal.valid?
  end
  
  test "invalid deal" do
    invalid_name = (0..80).map{"a"}.join
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :name => invalid_name)
    }
  end

  test "validates price" do
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :price => "")
    }
  end
  
  
  test "unique token added to new deal" do
    assert_nothing_raised do
      @deal = Factory(:deal, :name => 'deal name here')
    end
    assert_not_nil @deal.unique_token
  end
  
  test "validate unique token" do
    @user = Factory(:user)
    @category = Factory(:category)
    params = Factory.attributes_for(:deal, :category => @category, :user => @user)
    
    @deal0 = Factory(:deal, params)
    assert_raise(ActiveRecord::RecordInvalid) {
      @deal1 = Factory(:deal, params)
    }
  end
  
  # -------------
  # search
  test "can be located via Foursquare" do
    venue = { "name" => "Nuba", "location" => { "lat" => 49.282867, "lng" => -123.109587, "address" => "207 West Hastings" } }
    foursquare_client = mock
    foursquare_client.expects(:venue).with("4aa7fe08f964a520914e20e3").returns(venue)
    Qwiqq.expects(:foursquare_client).returns(foursquare_client)

    @deal = Factory(:deal, :location_name => nil, :foursquare_venue_id => "4aa7fe08f964a520914e20e3")
    @deal.locate_via_foursquare!
    @deal.reload # reload to make sure changes were commited

    assert_in_delta(49.282867, @deal.lat, 0.01)
    assert_in_delta(-123.109587, @deal.lon, 0.01)
    assert_equal "Nuba", @deal.foursquare_venue_name
    assert_equal "207 West Hastings", @deal.location_name
  end

  # -------------
  # Coupons
  test "detects when the coupon tag is not present" do
    @deal = Factory(:deal, :name => "This is a deal without a coupon.")
    
    assert_equal true, @deal.persisted?
    assert_equal false, @deal.coupon?
  end
 
  test "detects when the coupon tag is present" do
    @deal = Factory(:deal, :name => "This is a deal with a coupon. #coupon")
    
    assert_equal true, @deal.persisted?
    assert_equal true, @deal.coupon?
    assert_equal Deal::DEFAULT_COUPON_COUNT, @deal.coupon_count
  end

  test "does not redeem a coupon when none exist" do
    @deal = Factory(:deal, :name => "This is a deal without a coupon.")
    redeemed = @deal.redeem_coupon!
    @deal.reload
    
    assert_equal false, redeemed
  end

  test "redeems a coupon when coupons are available" do
    @deal = Factory(:deal, :name => "This is a deal with a coupon. #coupon")
    redeemed = @deal.redeem_coupon!
    @deal.reload
    
    assert_equal true, redeemed
    assert_equal Deal::DEFAULT_COUPON_COUNT - 1, @deal.coupon_count
  end

  test "does not redeem a coupon when none remain" do
    @deal = Factory(:deal, :name => "This is a deal with a coupon. #coupon")
    @deal.update_attribute(:coupon_count, 0)
    redeemed = @deal.redeem_coupon!
    @deal.reload
    
    assert_equal false, redeemed
    assert_equal 0, @deal.coupon_count
  end
end
