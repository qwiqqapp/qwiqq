class DealsController < ApplicationController
    
  def index
    respond_with Deal.limit(30)
  end
  
  
end