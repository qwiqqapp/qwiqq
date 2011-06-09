class Api::LikesController < Api::ApiController

  before_filter :require_user
  before_filter :find_deal

  def index
    @likes = @deal.likes
    respond_with @likes
  end
  
  def create
    @deal.likes.create(:user => current_user)
    respond_with @deal
  end

  def destroy
    @like = @deal.likes.find_by_user_id(current_user.id)
    @like.destroy if @like
    render :json => {}, :status => :ok 
  end

  private
  def find_deal
    @deal = Deal.find(params[:deal_id])
  end
end
