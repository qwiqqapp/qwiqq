class Api::SearchController < Api::ApiController

  # api/search/users
  def users
    @users = User.search_by_username(params[:q])
    respond_with @users
  end
  
  # api/search/deals          << considered as current, a redirect to the current default route
  # api/search/deals/:newest
  # api/search/deals/:nearby
  # api/search/deals/:popular
  def deals
  end
  
  # api/search/category/:name/deals
  def category
  end

end