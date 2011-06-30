class Api::FriendsController < Api::ApiController

  before_filter :find_user

  def index
    @friends = @user.friends
    respond_with @friends
  end

  def create
    @friend = User.find(params[:friend_id])
    @friendship = @user.create_friendship(@friend)
    @friendship.save!
    respond_with(@friendship, :location => false)
  end

  def pending
    @friends = @user.pending_friends
    respond_with @friends
  end

  def accept
    @friendship = @user.friendships.find_by_friend_id(params[:id])
    @friendship.accept!
    render :json => @friendship
  end

  def reject
    @friendship = @user.friendships.find_by_friend_id(params[:id])
    @friendship.reject!
    render :json => @friendship
  end

  private
    def find_user
      @user = super(params[:user_id])
    end
end
