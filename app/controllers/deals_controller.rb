class DealsController < ApplicationController
  caches_action :show, :cache_path => lambda {|c| "home/#{c.find_deal.cache_key}/#{c.ios?}" }

  def find_deal
    @deal ||= Deal.find(params[:id])
  end

  def index
    begin
      if city = GEO_IP.try(:city, request.remote_ip)
        @deals = Deal.nearby(city.latitude, city.longitude)
        logger.error @deals.inspect
      end
    rescue
    end

    @deals ||= Deal.unscoped.order("likes_count desc, comments_count desc").limit(6)

    respond_with @deals
  end
  
  def show
    respond_with find_deal
  end
end
