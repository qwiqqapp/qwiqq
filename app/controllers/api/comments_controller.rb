class Api::CommentsController < Api::ApiController

  before_filter :require_user, :only => [:create]
  caches_action :index, :cache_path => lambda {|c| "#{c.find_parent.cache_key}/comments" },
    :unless => lambda {|c| c.params[:page] }

  # return list of comments for deal or user:
  # - api/users/:user_id/comments => returns comments
  # - api/deals/:deal_id/comments => returns comments
  # - return 404 if neither deal_id or user_id provided
  
  def index
    @comments = find_parent.comments.includes(:user, :deal)
    respond_with(paginate(@comments), :include => [:user])
  end

  # auth required
  def create
    puts 'create new comment - start'
    
    @deal = Deal.find(params[:deal_id])
    @previous_comment = current_user.comments.first
<<<<<<< HEAD
    unless @previous_comment.body == params[:comment] && @previous_comment.deal.id == @deal.id
      puts "Comment not duplicate '#{@previous_comment.body}' '#{params[:comment]}'"
=======
    
    puts 'deal'
    puts @deal
    
    puts 'previous_comment'
    puts @previous_comment
    
    if @previous_comment.nil?
>>>>>>> e134569937b3a508db163691aae77410da2e2865
      @comment = @deal.comments.build(params[:comment])
      @comment.user = current_user
      @comment.save!
      respond_with(@comment, :location => false)  
    else
      unless @previous_comment.body == params[:comment] && @previous_comment.deal.id == @deal.id
        puts "Comment not duplicate"
        @comment = @deal.comments.build(params[:comment])
        @comment.user = current_user
        @comment.save!
        respond_with(@comment, :location => false)  
      end
    end

    puts 'create new comment - fini'
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
