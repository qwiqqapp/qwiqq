# notes
# unable to use search on users and models as ActiveAdmin 
# has poluted the app with its meta search implementation

class Api::SearchController < Api::ApiController

  skip_before_filter :require_user

  # api/search/users
  def users
    @users = User.search_by_name(params[:q])
    render :json => @users.as_json(:current_user => current_user)
  end
  
  # api/search/deals/newest
  # api/search/deals/nearby
  # api/search/deals/popular
  def deals
    @deals = Deal.indextank_search(params[:q], params[:filter], {:lat => params[:lat],:long => params[:long]})                                
    respond_with @deals
  end
  
  # api/search/category/:name/deals
  def category
    @deals = Deal.indextank_search(params[:name],'category', {:lat => params[:lat], :long => params[:long]})                
    respond_with @deals
  end
end
