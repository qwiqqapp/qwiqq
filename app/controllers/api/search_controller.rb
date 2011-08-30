# notes
# unable to use search on users and models as ActiveAdmin 
# has poluted the app with its meta search implementation

class Api::SearchController < Api::ApiController

  skip_before_filter :require_user
  caches_action :users, :cache_path => lambda {|c| "#{c.current_user.try(:cache_key)}/search/users/#{c.params[:q]}" }, :expires_in => 20.minutes

  # api/search/users
  def users

    @search = User.search do
      fulltext params[:q]
    end

    @users = @search.results
    render :json => @users.as_json(:current_user => current_user)
  end
  
  # path: api/search/deals/:filter
  # required params:
  # - params[:q]
  # - params[:filter] (newest | nearby | popular)
  # optional params
  # - params[:lat]
  # - params[:long]
  
  def deals
    @deals = Deal.search do
      fulltext params[:q] unless params[:q].empty?
      with(:coordinates).near(params[:lat], params[:long], :precision => 100) if (params[:lat].present? && params[:lng].present?)
    end
    respond_with @deals
  end

  
  # example: api/search/category/:name/deals
  # required param: params[:name]
  # optional params: params[:lat] + params[:long]
  
  def category
    respond_with @deals
  end
end

# 
# @results = Model.search do
#   order_by(:distance, :desc) # Order by distance from farthest to closest
# 
#   adjust_solr_params do |params|
#     params[:q] = "{!spatial qtype=dismax boost=#{some_boost_val} circles=#{search_lat},#{search_lng},#{search_radius}}" + "#{params[:q]}"
#   end
# end
