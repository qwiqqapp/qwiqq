class Api::RelationshipsController < Api::ApiController

  def create
    @user = current_user
    @target = User.find(params[:target_id])
    
    # dont allow self follow
    if @user == @target
      render :json => {:message => 'Unable to follow yourself' }, :status => 405
    else  
      @relationship = @user.follow!(@target)
      render :status => :created, :json => {
        :followers_count => @target.followers_count + 1,
        :following_count => @target.following_count,
        :friends_count =>   @target.friends_count }
    end
  end

  def destroy
    @user = current_user
    @relationship = @user.relationships.find_by_target_id(params[:target_id])
    @relationship.destroy
    render :status => :ok, :json => {
      :followers_count => @relationship.target.followers_count - 1,
      :following_count => @relationship.target.following_count,
      :friends_count =>   @relationship.target.friends_count }
  end

end

