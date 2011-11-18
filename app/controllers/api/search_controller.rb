# notes
# unable to use search on users and models as ActiveAdmin 
# has poluted the app with its meta search implementation

class Api::SearchController < Api::ApiController

  # temp remove action cache for users
  # caches_action :users, 
  #   :cache_path => lambda {|c| "#{c.current_user.try(:cache_key)}/search/users/#{c.params[:q]}" }, 
  #   :expires_in => 10.minutes

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
  # - params[:filter] = order (newest || popular || nearby)
  # - params[:lat], params[:long] (required when "filter" is "nearby")
  # - params[:q]
  # optional params
  # - params[:category]
  def deals
    @deals = Deal.filtered_search(params[:filter],
      :query => params[:q], 
      :lat => params[:lat], 
      :lon => params[:long], 
      :category => params[:category],
      :page => params[:page])
    render :json => paginate(@deals).compact.as_json(:minimal => true)
  end

  # example: api/search/category/:name/deals
  # required param: 
  # - params[:name]
  # optional params:
  # - params[:lat], params[:long]
  def category
    order = (params[:lat] and params[:long]) ? "nearby" : "relevance"
    @deals = Deal.filtered_search(order,
      :category => params[:name], 
      :lat => params[:lat], 
      :lon => params[:long],
      :page => params[:page])
    render :json => paginate(@deals).compact.as_json(:minimal => true)
  end
end
