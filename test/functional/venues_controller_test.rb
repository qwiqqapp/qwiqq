require "test_helper"

class Api::VenuesControllerTest < ActionController::TestCase
  test "should route to venues#index" do
    assert_routing("/api/venues.json", {:format => "json", :controller => "api/venues", :action => "index" })
  end

  test "should render venues near a location" do
    foursquare_client = mock
    fixture = File.read(Rails.root.join("test", "fixtures", "foursquare_venues.json"))
    response = JSON.parse(fixture)["response"]
    lon, lat = "49.282833", "-123.109698" 
    foursquare_client.expects(:search_venues).with(lon, lat).returns(response)
    Qwiqq.expects(:foursquare_client).returns(foursquare_client)

    get :index, :format => :json, :lon => lon, :lat => lat

    assert_equal 3, json_response.size
    assert_equal "Nuba", json_response[0]["name"]
    assert_equal "4aa7fe08f964a520914e20e3", json_response[0]["foursquare_id"]
    assert_equal "food", json_response[0]["category"]
    assert_equal "https://foursquare.com/img/categories/food/middleeastern.png", json_response[0]["icon"]
  end
end

