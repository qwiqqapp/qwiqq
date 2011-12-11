desc "Generates 'config/foursquare_categories.yml' which is used to convert foursquare categories."
task :generate_foursquare_categories_config => :environment do
  # mappable categories, at any level
  foursquare_category_map = {
    
    "Arts & Entertainment" => "ae",
    "Toy or Game Store" => "ae",
    "Video Game Store" => "ae",
    "Video Store" => "ae",
    "Bookstore" => "ae",
    "Hobby Shop" => "ae",
    "Internet Cafe" => "ae",
    "Music Store" => "ae",
    "Record Shop" => "ae",
    "Smoke Shop" => "ae",
    "College & University" => "ae",
    
    "Food" => "food",
    "Candy Store" => "food",    
    "Convenience Store" => "food",
    "Food and Drink Shop" => "food",
    "College Cafeteria" => "food",
    
    "Nightlife Spot" => "bar",
    
    "Antique Shop" => "home",
    "Arts & Crafts Store" => "home",
    "Flea Market" => "home",
    "Flower Shop" => "home",
    "Furniture or Home Store" => "home",
    "Hardware Store" => "home",
    "Gift Shop" => "home",
    "Drugstore or Pharmacy" => "home",
    "Laundromat or Dry Cleaner" => "home",
    "Convenience Store" => "home",
    "Professional & Other Places" => "home",
        
    "Bike Shop" => "sport",
    "Board Shop" => "sport",
    "Gyms or Fitness Center" => "sport",
    "Sporting Goods Shop" => "sport",
    "Yoga Studio" => "sport",
    "Great Outdoors" => "sport",

    "College Stadium" => "ae",
    "College Baseball Diamond" => "ae",
    "College Basketball Court" => "ae",
    "College Cricket Pitch" => "ae",
    "College Football Field" => "ae",
    "College Hockey Rink" => "ae",
    "College Soccer Field" => "ae",
    "College Tennis Court" => "ae",
    "College Track" => "ae",

    "Bridal Shop" => "fashion",
    "Clothing Store" => "fashion",
    "Jewelry Store" => "fashion",
    "Mall" => "fashion",    
    "Thrift or Vintage Store" => "fashion",
    "Department Store" => "fashion",

    "Salon or Barbershop" => "beauty",
    "Spa or Massage" => "beauty",
    "Tattoo Parlor" => "beauty",
    "Cosmetics Shop" => "beauty",
    "Tanning Salon" => "beauty",
    "Spa or Massage" => "beauty",
    
    "Electronics Store" => "tech",
    "Camera Store" => "tech",
    
    "Animal Shelter" => "pet",
    "Pet Stores" => "pet",
    
    "Automotive Shop" => "car",
    "Car Dealer" => "car"
  }

  categories = {}

  # a category can have sub and sub-sub categories:
  # https://developer.foursquare.com/docs/venues/categories.html
  foursquare_categories = Qwiqq.foursquare_client.categories || []
  foursquare_categories.each do |foursquare_category|
    # category
    category = foursquare_category_map[foursquare_category["name"]]
    categories[foursquare_category["name"]] = category if category

    foursquare_category["categories"].each do |foursquare_sub_category|
      # sub-category
      sub_category = foursquare_category_map[foursquare_sub_category["name"]] || category
      categories[foursquare_sub_category["name"]] = sub_category if sub_category

      foursquare_sub_category["categories"].each do |foursquare_sub_sub_category|
        # sub-sub-category
        sub_sub_category = foursquare_category_map[foursquare_sub_sub_category["name"]] || sub_category || category
        categories[foursquare_sub_sub_category["name"]] = sub_sub_category if sub_sub_category
      end
    end
  end

  File.open(Rails.root.join("config", "foursquare_categories.yml"), "w") do |f|
    f.write categories.to_yaml
  end
end

