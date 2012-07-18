class Api::RelationshipsController < Api::ApiController
  def create
    target = User.find(params[:target_id])
    if current_user == target
      render :status => 405, :json => { :message => 'Unable to follow yourself' }
    else  
      relationship = current_user.follow!(target)
      render :status => :created, :json => {
        :followers_count => target.followers_count + 1,
        :following_count => target.following_count,
        :friends_count =>   target.friends_count }
  end

  def destroy
    relationship = current_user.relationships.find_by_target_id(params[:target_id])
    if relationship
      relationship.destroy
      render :status => :ok, :json => {
        :followers_count => relationship.target.followers_count - 1,
        :following_count => relationship.target.following_count,
        :friends_count => relationship.target.friends_count }
    else
      render :status => 405, :json => { :message => 'Relationship does not exist' }
    end
  end
end

