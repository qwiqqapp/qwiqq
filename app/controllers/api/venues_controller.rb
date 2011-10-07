class Api::VenuesController < Api::ApiController
  skip_before_filter :require_user

  def index
    response = Qwiqq.foursquare_client.search_venues(params[:lon], params[:lat])

    venues = []
    (response["venues"] || []).each do |venue|
      #foursquare_category = venue["categories"].first {|c| c["primary"] }
      #category = convert_foursquare_category(foursquare_category) unless foursquare_category.nil? 
      venues << { 
        foursquare_id: venue["id"],
        name: venue["name"], 
        category: "", #category || "",
        icon: "", #foursquare_category["icon"]
        address: venue["location"]["address"],
        distance: venue["location"]["distance"]
      }
    end

    render :json => venues
  end

  private
    def convert_foursquare_category(foursquare_category)
      # convertable foursquare categories
      foursquare_categories = {
        "Arts & Entertainment" => "ae",
        "Food" => "food",
        "Nightlife Spots" => "food",
        "Shops & Services" => {
          "Antique Shops" => "used",
          "Arts & Crafts Stores" => "family",
          "Bike Shops" => "sport",
          "Board Shops" => "sport",
          "Bookstores" => "ae",
          "Bridal Shops" => "fashion",
          "Candy Stores" => "food",
          "Clothing Stores" => "fashion",
          "Convenience Stores" => "food",
          "Cosmetics Shops" => "beauty",
          "Department Stores" => "house",
          "Drugstores or Pharmacies" => "house",
          "Electronics Stores" => "tech",
          "Flea Markets" => "used",
          "Flower Shops" => "family",
          "Food and Drink Shops" => "food",
          "Furniture or Home Stores" => "home",
          "Gaming Cafes" => "ae",
          "Gift Shops" => "family",
          "Gyms or Fitness Centers" => "sports",
          "Hardware Stores" => "house",
          "Hobby Shops" => "ae",
          "Internet Cafes" => "ae",
          "Jewelry Stores" => "fashion",
          "Laundromats or Dry Cleaners" => "house",
          "Malls" => "fashion",
          "Music Stores" => "ae",
          "Record Shops" => "ae",
          "Salons or Barbershops" => "beauty",
          "Spas or Massages" => "beauty",
          "Tattoo Parlors" => "beauty",
          "Thrift or Vintage Stores" => "used",
          "Toy or Game Stores" => "ae",
          "Video Game Stores" => "ae",
          "Video Stores" => "ae" }
        }

      foursquare_parent_category = foursquare_category["parents"].first
      category = foursquare_categories[foursquare_parent_category]
      if category.is_a? Hash
        category = category[foursquare_category["pluralName"]]
      end
      category
    end
end

