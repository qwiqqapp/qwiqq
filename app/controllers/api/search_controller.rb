# notes
# unable to use search on users and models as ActiveAdmin 
# has poluted the app with its meta search implementation

class Api::SearchController < Api::ApiController

  caches_action :users, 
    :cache_path => lambda {|c| "#{c.current_user.try(:cache_key)}/search/users/#{c.params[:q]}" }, 
    :expires_in => 10.minutes

  skip_before_filter :require_user
  
    
  # api/search/users
  def users
    @users = User.search(params[:q])
    render :json => @users.as_json(:current_user => current_user)
  end
  
  # path: api/search/deals/:filter
  # required params:
  # - params[:q]
  # - params[:filter] = order (newest | nearby | popular)
  # optional params
  # - params[:lat]
  # - params[:long]
  
  def deals
    @users = Deal.search(params[:q])
    respond_with @deals
  end

  # example: api/search/category/:name/deals
  # required param: params[:name]
  # optional params: params[:lat] + params[:long]
  def category
    @deals = Deal.category_search(params[:name], params[:lat], params[:long])
    respond_with @deals
  end
end