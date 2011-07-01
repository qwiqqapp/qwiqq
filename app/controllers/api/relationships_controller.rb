class Api::RelationshipsController < Api::ApiController

  def create
    @user = find_user(params[:user_id])
    @target = User.find(params[:target_id])
    @relationship = @user.follow!(@target)
    respond_with(@relationship, :location => false)
  end

  def destroy
    @user = find_user(params[:user_id])
    @relationship = @user.relationships.find_by_target_id(params[:target_id])
    @relationship.destroy
    render :status => :ok, :json => {}
  end

end

