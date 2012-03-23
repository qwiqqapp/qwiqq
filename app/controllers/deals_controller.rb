class DealsController < ApplicationController
  caches_action :show, :cache_path => lambda {|c| "home/#{c.find_deal.cache_key}/#{c.ios?}" }

  def index
    @deals = Deal.popular.limit(6)
    render layout: 'home'
  end
  
  def show
    @deal = find_deal
    @events = @deal.events
  end

  def nearby
    lat, lon = find_location
    @deals = Deal.filtered_search(:lat => lat, :lon => lon).compact.first(6) if lat and lon
    if @deals.blank?
      render :status => 200, :text => ""
    else
      render :layout => false
    end
  end

  def find_deal
    @deal ||= Deal.find(params[:id])
  end

  private
  def find_location
    ip = request.remote_ip
    response = HTTParty.get("http://qwiqq-geoip.heroku.com/location.json?ip=#{ip}")
    if response and response.code == 200
      [ response["latitude"], response["longitude"] ]
    end
  end
end

