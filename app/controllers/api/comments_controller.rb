class Api::CommentsController < Api::ApiController

  before_filter :require_user, :only => [:create]
  caches_action :index, :cache_path => lambda {|c| "#{c.find_parent.cache_key}/comments" }

  # return list of comments for deal or user:
  # - api/users/:user_id/comments => returns comments
  # - api/deals/:deal_id/comments => returns comments
  # - return 404 if neither deal_id or user_id provided
  
  def index
    @comments = find_parent.comments.includes(:user, :deal)
    respond_with(@comments, :include => [:user])
  end

  # auth required
  def create
    @deal = Deal.find(params[:deal_id])
    @comment = @deal.comments.build(params[:comment])
    @comment.user = current_user
    @comment.save!
    respond_with(@comment, :location => false)
  end
  
  def destroy
    @comment = current_user.comments.find(params[:id])
    @comment.destroy
    respond_with(@comment, :location => false)
  end
  
  def find_parent
    @parent ||= 
      if params[:deal_id]
        Deal.find(params[:deal_id])
      elsif params[:user_id]
        find_user(params[:user_id])
      else
        raise RecordNotFound
      end
  end
end
