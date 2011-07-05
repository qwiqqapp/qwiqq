class Api::UsersController < Api::ApiController

  skip_before_filter :require_user, :only => [:create, :show]

  # will raise RecordNotFound if user not found
  # will render 401 if email does not match
  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
    end
    respond_with :api, @user
  end

  def update
    # only the current user can be updated
    raise ActiveRecord::RecordNotFound unless params[:id] == "current"
    current_user.update_attributes(params[:user])
    render :json => current_user.as_json
  end
  
  # phase 1: return full details
  # phase 2: return full for friends and limited for non friends
  def show
    @user = find_user(params[:id])
    render :json => @user.as_json(:deals => true, :comments => true)
  end

  def followers
    @user = find_user(params[:id])
    @followers = @user.followers
    respond_with @followers
  end

  def following
    @user = find_user(params[:id])
    @following = @user.following
    respond_with @following
  end

  def friends
    @user = find_user(params[:id])
    @friends = @user.friends
    respond_with @friends
  end
  
end
