class DealsController < ApplicationController
  # caches_action :show, :cache_path => lambda {|c| "home/#{c.find_deal.cache_key}/#{c.ios?}" }


  # TODO either cache action or memoize @deals 
  def index
    @deals = Deal.premium.recent.sorted.popular.first(9)
    render layout: 'home'
  end
  
  def show
    @deal = find_deal
    @events = @deal.events
  end

  # the geoip service was not accurate enough so using suggested users posts as stopgap
  # TODO update nearby to use HTML5 location
  def nearby
    lat, lon = find_location
    if lat and lon
      @deals =  Deal.filtered_search(:lat => lat, :lon => lon, :range => Deal::MAX_RANGE*2).compact.first(6)
    else
      @deals = []
    end
    
    render layout: false
  end
  
  def find_deal
    @deal ||= Deal.find(params[:id])
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
      [ response["latitude"], response["longitude"] ]
    end
  end
end

