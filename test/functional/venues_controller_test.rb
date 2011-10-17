require "test_helper"

class Api::VenuesControllerTest < ActionController::TestCase
  test "should route to venues#index" do
    assert_routing("/api/venues.json", {:format => "json", :controller => "api/venues", :action => "index" })
  end
  
  test "should render venues near a location" do
    fixture = File.read(Rails.root.join("test", "fixtures", "foursquare_venues.json"))
    venues = JSON.parse(fixture)
    lat, lon = "49.282833", "-123.109698"
    foursquare_client = mock
    foursquare_client.expects(:search_venues).with(lat, lon, "").returns(venues)
    Qwiqq.expects(:foursquare_client).returns(foursquare_client)

    get :index, :format => :json, :lat => lat, :lon => lon

    assert_equal 30, json_response.size
    assert_equal "Nuba", json_response[0]["name"]
    assert_equal "4aa7fe08f964a520914e20e3", json_response[0]["foursquare_id"]
    assert_equal "food", json_response[0]["category"]
    assert_equal "https://foursquare.com/img/categories/food/middleeastern_256.png", json_response[0]["icon"]
  end

  test "should render venues near a location with a search string" do
    fixture = File.read(Rails.root.join("test", "fixtures", "foursquare_venues_tacos.json"))
    venues = JSON.parse(fixture)
    lat, lon = "49.282833", "-123.109698"
    foursquare_client = mock
    foursquare_client.expects(:search_venues).with(lat, lon, "tacos").returns(venues)
    Qwiqq.expects(:foursquare_client).returns(foursquare_client)

    get :index, :format => :json, :lat => lat, :lon => lon, :query => "tacos"

    assert_equal 30, json_response.size
    assert_equal "Los Tacos Cafe", json_response[0]["name"]
    assert_equal "4e8a11fde5faea170a4d231d", json_response[0]["foursquare_id"]
    assert_equal "food", json_response[0]["category"]
    assert_equal "https://foursquare.com/img/categories/food/tacos_256.png", json_response[0]["icon"]
  end

  test "should handle when Foursquare returns no venues" do
    lon, lat = "0.0", "0.0" 
    foursquare_client = mock
    foursquare_client.expects(:search_venues).with(lon, lat, "").returns(nil)
    Qwiqq.expects(:foursquare_client).returns(foursquare_client)

    get :index, :format => :json, :lon => lon, :lat => lat

    assert_equal 0, json_response.size
  end
end

