# because all existing foursquare clients are broken
class Foursquare
  include HTTParty
  base_uri "https://api.foursquare.com/v2"
  default_params :v => "20110930" # see http://bit.ly/lZx3NU

  def initialize(options)
    @client_id = options[:client_id]
    @client_secret = options[:client_secret]
    @access_token = options[:access_token]
  end
  
  def search_venues(lon, lat)
    response = self.class.get("/venues/search", { :query => { 
      :ll => "#{lat},#{lon}", 
      :client_id => @client_id, 
      :client_secret => @client_secret } } )
    response["response"]["venues"]
  end

  def categories
    response = self.class.get("/venues/categories", { :query => {
      :client_id => @client_id, 
      :client_secret => @client_secret } } )
    response["response"]["categories"]
  end

  def users(user_id)
    response = self.class.get("/users/#{user_id}", { :query => { 
      :oauth_token => @access_token }})
    response["response"]
  end

  def checkin(venue_id, shout)
    response = self.class.post("/checkins/add", { :query => { 
      :venueId => venue_id,
      :shout => shout,
      :broadcast => "public",
      :oauth_token => @access_token }})
    response["response"]
  end

  def shout(shout)
    response = self.class.post("/checkins/add", { :query => { 
      :shout => shout,
      :broadcast => "public",
      :oauth_token => @access_token }})
    response["response"]
  end
end

