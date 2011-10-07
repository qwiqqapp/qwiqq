desc "Generates 'config/foursquare_categories.yml' which is used to convert foursquare categories."
task :generate_foursquare_categories_config => :environment do
  # mappable categories, at any level
  foursquare_category_map = {
    "Arts & Entertainment" => "ae",
    "Food" => "food",
    "Nightlife Spot" => "food",
    "Antique Shop" => "used",
    "Arts & Crafts Store" => "family",
    "Bike Shop" => "sport",
    "Board Shop" => "sport",
    "Bookstore" => "ae",
    "Bridal Shop" => "fashion",
    "Candy Store" => "food",
    "Clothing Store" => "fashion",
    "Convenience Store" => "food",
    "Cosmetics Shop" => "beauty",
    "Department Store" => "house",
    "Drugstore or Pharmacy" => "house",
    "Electronics Store" => "tech",
    "Flea Market" => "used",
    "Flower Shop" => "family",
    "Food and Drink Shop" => "food",
    "Furniture or Home Store" => "home",
    "Gaming Cafe" => "ae",
    "Gift Shop" => "family",
    "Gyms or Fitness Center" => "sports",
    "Hardware Store" => "house",
    "Hobby Shop" => "ae",
    "Internet Cafe" => "ae",
    "Jewelry Store" => "fashion",
    "Laundromat or Dry Cleaner" => "house",
    "Mall" => "fashion",
    "Music Store" => "ae",
    "Record Shop" => "ae",
    "Salon or Barbershop" => "beauty",
    "Spa or Massage" => "beauty",
    "Tattoo Parlor" => "beauty",
    "Thrift or Vintage Store" => "used",
    "Toy or Game Store" => "ae",
    "Video Game Store" => "ae",
    "Video Store" => "ae"
  }

  categories = {}

  # a category can have sub and sub-sub categories:
  #   https://developer.foursquare.com/docs/venues/categories.html
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

