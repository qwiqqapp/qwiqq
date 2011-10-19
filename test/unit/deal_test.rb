require 'test_helper'

class DealTest < ActiveSupport::TestCase
  
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

  test "validates percent is a percentage" do
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :percent => 101)
    }
  end

  test "validates price" do
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :price => "", :percent => nil)
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
    params = {:name => 'test', :price => 5, :category_id => @category.id, :user_id => @user.id, :percent => nil}
    
    @deal0 = Factory(:deal, params)
    assert_raise(ActiveRecord::RecordInvalid) {
      @deal1 = Factory(:deal, params)
    }
  end
  
  # -------------
  # search
  
  test "filtered search without query should not raise" do
    assert_nothing_raised do
      @deals = Deal.filtered_search(' ', 'popular')
    end
    assert_equal [], @deals
  end

  test "can be located via Foursquare" do
    venue = { "name" => "Nuba", "location" => { "lat" => 49.282867, "lng" => -123.109587, "address" => "207 West Hastings" } }
    foursquare_client = mock
    foursquare_client.expects(:venue).with("4aa7fe08f964a520914e20e3").returns(venue)
    Qwiqq.expects(:foursquare_client).returns(foursquare_client)

    @deal = Factory(:deal, :location_name => nil, :foursquare_venue_id => "4aa7fe08f964a520914e20e3")
    @deal.locate_via_foursquare!
    @deal.reload # reload to make sure changes were commited

    assert_in_delta 49.282867, @deal.foursquare_venue_lat, 0.01
    assert_in_delta -123.109587, @deal.foursquare_venue_lon, 0.01
    assert_equal "Nuba", @deal.foursquare_venue_name
    assert_equal "207 West Hastings", @deal.location_name
  end
 
end

