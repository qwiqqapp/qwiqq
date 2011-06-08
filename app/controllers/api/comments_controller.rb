class Api::CommentsController < Api::ApiController

  before_filter :require_user
  before_filter :find_deal

  def index
    @comments = @deal.comments
    respond_with @comments
  end
  
  def create
    @comment = @deal.comments.build(params[:comment])
    @comment.user = current_user
    @comment.save!
    respond_with(@comment, :location => false)
  end

  private
  def find_deal
    @deal = Deal.find(params[:deal_id])
  end
end
