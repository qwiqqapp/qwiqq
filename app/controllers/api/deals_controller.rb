class Api::DealsController < Api::ApiController
  
  skip_before_filter :require_user, :only => [:popular, :feed]
  
  
  # ------------------
  # no auth required
  
  def popular
    @deals = Deal.order("like_count desc, comment_count desc").limit(32).includes(:category)
    respond_with @deals
  end
  
  # ------------------
  # public scope
  
  
  # will develop this in phases
  # phase 1: recent public deals
  # phase 2: add location order
  # phase 3: only deals from friends
  def feed
    @deals = Deal.order("premium desc").order("created_at").limit(32).includes(:category)
    raise RecordNotFound unless @deals
    respond_with @deals
  end
  
  def show
    @deal = Deal.find(params[:id])
    respond_with @deal
  end

  def search
    query = params[:q]
    @deals = Deal.search(query)
    respond_with @deals
  end
  
  # -----------------
  # scoped to user
  
  def index
    @deals = current_user.deals
    raise RecordNotFound unless @deals
    respond_with @deals
  end
  
  
  # move this logic to model once finalized
  def create
    category = Category.find_by_name!(params[:deal][:category_name])
    @deal = Deal.new(params[:deal])
    @deal.category = category
    @deal.user = current_user
    @deal.save!
    
    respond_with @deal
  end

end