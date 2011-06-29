class Api::FriendsController < Api::ApiController

  def index
    @friends = current_user.friends
    respond_with @friends
  end

  def create
    @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
    @friendship.save!
    respond_with(@friendship, :location => false)
  end

  def pending
    @friends = current_user.pending_friends
    respond_with @friends
  end

  def accept
    @friendship = current_user.friendships.find_by_friend_id(params[:id])
    @friendship.accept!
    render :json => @friendship
  end

  def reject
    @friendship = current_user.friendships.find_by_friend_id(params[:id])
    @friendship.reject!
    render :json => @friendship
  end

end
