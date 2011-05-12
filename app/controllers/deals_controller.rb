class DealsController < ApplicationController
    
  def index
    @deals = Deal.limit(10)
    respond_with @deals
  end
  
  def show
    @deal = Deal.find(params[:id])
    respond_with @deal
  end
  
  
end