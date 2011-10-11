class Api::VenuesController < Api::ApiController
  skip_before_filter :require_user

  def index
    venues = Qwiqq.foursquare_client.search_venues(params[:lat], params[:lon], params[:query] || "") || []

    result = []
    venues.each do |venue|
      foursquare_categories = venue["categories"] || []
      foursquare_category = foursquare_categories.first {|c| c["primary"] } || foursquare_categories.first
      category = Qwiqq.convert_foursquare_category(foursquare_category["name"]) if foursquare_category
      icon = build_icon_url(foursquare_category["icon"]) if foursquare_category
      result << { 
        foursquare_id: venue["id"],
        name: venue["name"], 
        category: category || "",
        icon: icon || "",
        address: venue["location"]["address"],
        distance: venue["location"]["distance"]
      }
    end

    render :json => result
  end

  private
    def build_icon_url(icon)
      icon["prefix"] + icon["sizes"].last.to_s + icon["name"]
    end
end

