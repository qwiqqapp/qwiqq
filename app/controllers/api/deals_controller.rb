class Api::DealsController < Api::ApiController
  
  # ------------------
  # public scope
  
  
  # will develop this in phases
  # phase 1: recent public deals
  # phase 2: add location order
  # phase 3: only deals from friends
  def feed
    @deals = Deal.order("created_at desc").limit(30)
    raise RecordNotFound unless @deals
    respond_with @deals
  end
  
  def show
    @deal = Deal.find(params[:id])
    respond_with @deal
  end
  
  # -----------------
  # scoped to user
  
  def index
    @deals = current_user.deals
    raise RecordNotFound unless @deals
    respond_with @deals
  end
  
  def create
    @deal = Deal.new(params[:deal])
    @deal.user = current_user
    @deal.save!
    
    respond_with @deal
  end
  
end