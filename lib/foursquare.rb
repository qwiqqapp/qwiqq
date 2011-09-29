# because all existing foursquare clients are broken
class Foursquare
  include HTTParty
  base_uri "https://api.foursquare.com/v2"
  default_params :v => "20110930" # see http://bit.ly/lZx3NU

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret
  end
  
  def search_venues(lon, lat)
    response = self.class.get("/venues/search", { :query => { 
      :ll => "#{lon},#{lat}", 
      :client_id => @client_id, 
      :client_secret => @client_secret } } )
    
    pp response.body
    pp response.parsed_body
    pp response
      
    response["response"]
  end
end

