class Api::VenuesController < Api::ApiController
  skip_before_filter :require_user

  def index
    venues = Qwiqq.foursquare_client.venue_search("#{params[:lat]}, #{params[:lon]}", :query => params[:query] || "") || []

    result = []
    venues.each do |venue|
      foursquare_categories = venue["categories"] || []
      foursquare_category = foursquare_categories.first {|c| c["primary"] } || foursquare_categories.first
      category = Qwiqq.convert_foursquare_category(foursquare_category["name"]) if foursquare_category
      icon = build_icon_url(foursquare_category["icon"]) if foursquare_category
      category ||= Qwiqq.default_category.name
      result << { 
        foursquare_id: venue["id"],
        name: venue["name"], 
        category: category,
        icon: icon || "",
        address: venue["location"]["address"],
        distance: venue["location"]["distance"]
      }
    end
    
    render :json => result
  end

  private
    # default to size = 256 and .png
    def build_icon_url(icon)
      icon_url = ""
      icon_url << icon["prefix"]
      icon_url << (icon["sizes"].nil? ? '256' : icon["sizes"].last.to_s)
      icon_url << icon["name"] || '.png'
      icon_url
    end
end

