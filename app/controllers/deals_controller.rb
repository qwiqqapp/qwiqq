class DealsController < ApplicationController
  def index
    @deals = Deal.unscoped.order("like_count desc, comment_count desc").limit(15)
    respond_with @deals
  end
  
  def show
    redirect_to "qwiqq:///deals/#{params[:id]}" and return if ios?
    @deal = Deal.find(params[:id])
    respond_with @deal
  end
end
