class Api::DealsController < Api::ApiController
  
  skip_before_filter :require_user, :only => [:index, :show]
  
  
  # not scoped
  def index
    @deals = Deal.limit(28)
    raise RecordNotFound unless @deals
    respond_with @deals
  end
  
  # not scoped
  def show
    @deal = Deal.find(params[:id])
    respond_with @deal
  end
  
  
  # scoped to user
  def create
    @deal = Deal.new(params[:deal])
    @deal.user = current_user
    @deal.save!
    
    respond_with @deal
  end
  
end