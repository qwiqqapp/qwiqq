class Api::UsersController < Api::ApiController

  skip_before_filter :require_user, :only => [:create, :show, :followers, :following, :friends]

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
    @user = current_user
    @user.update_attributes(params[:user])
    respond_with(:api, @user) do
      render :json => @user.as_json and return if @user.valid?
    end
  end
  
  def show
    @user = find_user(params[:id])
    render :json => @user.as_json(
      :current_user => params[:id] == "current" ? false : current_user,
      :deals => true, 
      :comments => true)
  end

  def followers
    @user = find_user(params[:id])
    @followers = @user.followers.sorted
    respond_with @followers
  end

  def following
    @user = find_user(params[:id])
    @following = @user.following.sorted
    respond_with @following
  end

  def friends
    @user = find_user(params[:id])
    @friends = @user.friends.sorted
    respond_with @friends
  end
  
end

