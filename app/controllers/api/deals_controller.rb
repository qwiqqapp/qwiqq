class Api::DealsController < Api::ApiController
  
  def index
    @deals = Deal.limit(20)
    raise RecordNotFound unless @deals
    respond_with @deals
  end
  
  def show
    @deal = Deal.find(params[:id])
    respond_with @deal
  end
  
  
end