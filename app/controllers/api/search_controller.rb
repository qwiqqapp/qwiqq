# notes
# unable to use search on users and models as ActiveAdmin 
# has poluted the app with its meta search implementation

class Api::SearchController < Api::ApiController

  skip_before_filter :require_user
  caches_action :users, :cache_path => lambda {|c| "#{c.current_user.try(:cache_key)}/search/users/#{c.params[:q]}" }, :expires_in => 20.minutes

  # api/search/users
  def users
    @users = User.sorted.search_by_name(params[:q])
    render :json => @users.as_json(:current_user => current_user)
  end
  
  # api/search/deals/newest
  # api/search/deals/nearby
  # api/search/deals/popular
  #  option lat + long params
  def deals

    respond_with @deals
  end
  
  # api/search/category/:name/deals
  #  option lat + long params
  def category
    respond_with @deals
  end
end
