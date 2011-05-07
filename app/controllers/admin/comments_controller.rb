class Admin::CommentsController < Admin::AdminController
  
  def index
    @comments = Comment.limit(300).includes(:user, :deal)
    @title = "#{@comments.size} Comments"
  end
  
  
end