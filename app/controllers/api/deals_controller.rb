class Api::DealsController < Api::ApiController
  
  def index
    @deals = current_user.deals
    raise RecordNotFound unless @deals
    respond_with @deals
  end
  
  def show
    @deal = Deal.find!(params[:id])
    respond_with @deal
  end
  
  
  def featured
    @deals = Deal.limit(40)
    respond_with @deals
  end
    
  
end