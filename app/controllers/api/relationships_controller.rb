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
      target_deals = target.deals.sorted
      if target_deals
        target_deals.each do |deal|
          Feedlet.new(:user_id => current_user.id.try, 
                    :deal_id => deal.id.try, 
                    :posting_user_id => target.id.try, 
                    :reposted_by => nil, 
                    :timestamp => deal.created_at) end
      end
    end
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

