class Api::DealsController < Api::ApiController
  
  skip_before_filter :require_user
  
  def index
    @deals = Deal.limit(10)
    raise RecordNotFound unless @deals
    respond_with @deals
  end
  
  def show
    @deal = Deal.find(params[:id])
    respond_with @deal
  end
  
end