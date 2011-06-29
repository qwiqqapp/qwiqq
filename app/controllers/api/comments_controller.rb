class Api::CommentsController < Api::ApiController

  before_filter :require_user, :only => [:create]
  before_filter :find_deal, :only => [:create]

  # return list of comments for deal or user:
  # - api/users/:user_id/comments => returns comments
  # - api/deals/:deal_id/comments => returns comments
  # - return 404 if neither deal_id or user_id provided
  
  def index
    if params[:deal_id]
      @deal         = Deal.find(params[:deal_id])
      @collection   = @deal.comments.includes(:user, :deal)
    elsif params[:user_id]
      @user         = User.find(params[:user_id])
      @collection   = @user.comments.includes(:user, :deal)
    else
      raise RecordNotFound
    end
    
    respond_with(@collection, :include => [:user])
  end

  # auth required
  def create
    @comment = @deal.comments.build(params[:comment])
    @comment.user = current_user
    @comment.save!
    respond_with(@comment, :location => false)
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    
    
  end
  

  private
  def find_deal
    @deal = Deal.find(params[:deal_id])
  end
end
