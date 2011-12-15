class DealsController < ApplicationController
  caches_action :show, :cache_path => lambda {|c| "home/#{c.find_deal.cache_key}/#{c.ios?}" }

  def find_deal
    @deal ||= Deal.find(params[:id])
  end

  def index
    @deals = Deal.unscoped.order("likes_count desc, comments_count desc").limit(6)
    respond_with @deals
  end
  
  def show
    @deal = find_deal
    @events = @deal.events
    respond_with @deal
  end
end
