class Api::LikesController < Api::ApiController
  
  before_filter :require_user, :only => [:create, :destroy]
  
  # return list of likes for deal or user:
  # - api/users/:user_id/likes => returns deals
  # - api/deals/:deal_id/likes => returns users
  # - return 404 if neither deal_id or user_id provided
  def index
    if params[:deal_id]
      @deal         = Deal.find(params[:deal_id])
      @collection   = @deal.liked_by_users
    elsif params[:user_id]
      @user         = find_user(params[:user_id])
      @collection   = @user.liked_deals.sorted
    else
      raise RecordNotFound
    end
    
    respond_with @collection
  end
  
  # auth required
  def create
    @deal = Deal.find(params[:deal_id])
    @deal.likes.create(:user => current_user)
    respond_with @deal
  end

  # auth required
  def destroy
    @deal = Deal.find(params[:deal_id])
    @like = @deal.likes.find_by_user_id(current_user.id)
    @like.destroy if @like
    respond_with @like
  end
end
