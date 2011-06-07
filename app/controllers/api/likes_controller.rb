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

  private
  def find_deal
    @deal = Deal.find(params[:deal_id])
  end
end
