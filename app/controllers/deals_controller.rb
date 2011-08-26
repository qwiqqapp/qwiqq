class DealsController < ApplicationController
  caches_action :index, :expires_in => 10.minutes
  # caches_action :show, :if => lambda {|c| !c.ios? }, :cache_path => lambda {|c| "home/#{c.find_deal.cache_key}" }

  def find_deal
    @deal ||= Deal.find(params[:id])
  end

  def index
    @deals = Deal.unscoped.order("likes_count desc, comments_count desc").limit(15)
    respond_with @deals
  end
  
  def show
    redirect_to "qwiqq:///deals/#{params[:id]}" and return if ios?
    respond_with find_deal
  end
end
