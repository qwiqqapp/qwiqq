class Api::UsersController < Api::ApiController

  skip_before_filter :require_user, :only => [:create, :show, :followers, :following, :friends]
  caches_action :show, :cache_path => lambda {|c|
    (c.current_user.try(:cache_key) || "guest") + "/" + c.requested_user.cache_key
  } # expires automatically when users cache key changes or deals cache key changes

  caches_action :followers, :cache_path => lambda {|c| "followers/#{c.requested_user.cache_key}/#{c.params[:page]}" }
  caches_action :following, :cache_path => lambda {|c| "following/#{c.requested_user.cache_key}/#{c.params[:page]}" }
  caches_action :friends, :cache_path => lambda {|c| "friends/#{c.requested_user.cache_key}/#{c.params[:page]}" }

  def requested_user
    @user ||= find_user(params[:id])

  end

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
      render :json => @user.as_json(:current_user => current_user) and return if @user.valid?
    end
  end
  
  def show
    requested_user
    render :json => @user.as_json(
      :current_user => current_user,
      :deals => true, 
      :comments => true)
  end

  def followers
    requested_user
    @followers = @user.followers.sorted
    respond_with paginate(@followers)
  end

  def following
    requested_user
    @following = @user.following.sorted
    respond_with paginate(@following)
  end

  def friends
    requested_user
    @friends = @user.friends
    respond_with paginate(@friends.all)
  end

  
end

