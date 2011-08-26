# notes
# unable to use search on users and models as ActiveAdmin 
# has poluted the app with its meta search implementation

class Api::SearchController < Api::ApiController

  skip_before_filter :require_user
  caches_action :category, :cache_path => lambda {|c| "search/categories/#{c.params[:name]}" }, :expires_in => 10.minutes
  caches_action :users, :cache_path => lambda {|c| "search/users/#{c.params[:q]}" }, :expires_in => 20.minutes

  # api/search/users
  def users
    @users = User.sorted.search_by_name(params[:q])
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
