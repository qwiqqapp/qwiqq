class DealsController < ApplicationController
  # caches_action :show, :cache_path => lambda {|c| "home/#{c.find_deal.cache_key}/#{c.ios?}" }

  def index
    render layout: 'home'
  end
  
  def show
    @deal ||= Deal.find(params[:id])
    @events = @deal.events
  end

  def nearby
    lat, lon, @city_name = find_location
    
    if lat and lon
      @deals =  Deal.filtered_search(:lat => lat, :lon => lon).compact.first(6)
    else
      @deals = []
    end
    render layout: false
  end

  private
  def find_location
    if Rails.env.development?
      ip = '96.49.202.116' #for easy testing
    else
      ip = request.remote_ip
    end
    
    response = HTTParty.get("http://qwiqq-geoip.heroku.com/location.json?ip=#{ip}")
    if response and response.code == 200
      [ response["latitude"], response["longitude"], response['city_name']]
    end
  end
end

