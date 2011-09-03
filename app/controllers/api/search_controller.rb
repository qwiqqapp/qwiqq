# notes
# unable to use search on users and models as ActiveAdmin 
# has poluted the app with its meta search implementation

class Api::SearchController < Api::ApiController

  caches_action :users, 
    :cache_path => lambda {|c| "#{c.current_user.try(:cache_key)}/search/users/#{c.params[:q]}" }, 
    :expires_in => 10.minutes

  skip_before_filter :require_user
  
    
  # api/search/users
  # required param:
  # - params[:q]
  def users
    @users = User.search(params[:q])
    render :json => @users.as_json(:current_user => current_user)
  end
  
  # path: api/search/deals/:filter
  # required params:
  # - params[:filter] = order (newest | nearby | popular)
  # - params[:q]
  # optional params
  # - params[:lat]
  # - params[:long]
  def deals
    @deals = Deal.filtered_search(params[:q], params[:filter], params[:lat], params[:long])
    render :json => @deals.compact.as_json(:minimal => true)
  end
  
  # example: api/search/category/:name/deals
  # required param: params[:name]
  # optional params: params[:lat] + params[:long]
  def category
    @deals = Deal.category_search(params[:name], params[:lat], params[:long])
    render :json => @deals.compact.as_json(:minimal => true)
  end
end
