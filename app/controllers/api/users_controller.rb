class Api::UsersController < Api::ApiController

  skip_before_filter :require_user, :only => [:create]

  # will raise RecordNotFound if user not found
  # will render 401 if email does not match
  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
    end
    respond_with :api, @user
  end
  
  # phase 1: return full details
  # phase 2: return full for friends and limited for non friends
  def show
    @user = User.find(params[:id])
    respond_with @user
  end
  
  # return full details
  def current
    respond_with current_user
  end
end
