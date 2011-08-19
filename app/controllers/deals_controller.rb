class DealsController < ApplicationController
  def index
    @deals = Deal.unscoped.order("likes_count desc, comments_count desc").limit(15)
    respond_with @deals
  end
  
  def show
    redirect_to "qwiqq:///deals/#{params[:id]}" and return if ios?
    @deal = Deal.find(params[:id])
    respond_with @deal
  end
end
