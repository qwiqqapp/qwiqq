class Api::DealsController < Api::ApiController
  
  skip_before_filter :require_user, :only => [:popular, :show]
  
  # ------------------
  # no auth required
  
  def popular
    @deals = Deal.unscoped.order("like_count desc, comment_count desc").limit(64).includes(:category)
    respond_with @deals
  end
  
  # ------------------
  # public scope
  
  # will develop this in phases
  # phase 1: recent public deals
  # phase 2: add location order
  # phase 3: only deals from friends
  def feed
    @deals = current_user.feed_deals.limit(40).includes(:category)
    raise RecordNotFound unless @deals
    respond_with @deals
  end
  
  def show
    @deal = Deal.find(params[:id])
    # TODO it would be better to use standard rails conventions here,
    # i.e. :include => [ :comments, :liked_by_users ]
    render :json => @deal.as_json(:current_user => current_user,
                                  :comments => true, 
                                  :liked_by_users => true)
  end
  
  def index
    @deals = find_user(params[:user_id]).deals
    raise RecordNotFound unless @deals
    respond_with @deals
  end
  
  # -----------------
  # scoped to user

  # TODO move this logic to model once finalized
  def create
    category = Category.find_by_name(params[:deal][:category_name])
    @deal = Deal.new(params[:deal])
    @deal.category = category
    @deal.user = current_user
    @deal.save
    respond_with @deal
  end

  def update
    @deal = current_user.deals.find(params[:id])
    @deal.update_attributes(params[:deal])
    respond_with @deal
  end

  def repost
    @deal = Deal.find(params[:id])
    @user = find_user(params[:user_id])
    @reposted_deal = @user.repost_deal!(@deal)
    respond_with @reposted_deal, :location => false
  end

  def destroy
    @deal = current_user.deals.find(params[:id])
    @deal.destroy
    respond_with @deal
  end

end