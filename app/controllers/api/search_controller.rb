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
    puts "SEARCH USERS"
    @users = User.search(params[:q])
    puts "SEARCH USERS COUNT:#{@users.count}"
    render :json => @users.as_json(:current_user => current_user)
  end
  
  #get user id for username
  def username
    @user = User.find(:first, :conditions => [ "lower(username) = ?", params[:username].downcase])
    unless @user.nil?
      puts "username - #{@user.id}"
      json = {:id => @user.id}
      render :json => json
    else
      puts "username - couldn't find #{params[:username].downcase}"
      render :nothing => true
    end
  end
  
  # path: api/search/deals/nearby
  # path: api/search/deals
  # required params:
  # - params[:lat], params[:long], params[:range]
  # optional params
  # - params[:q]
  # - params[:category]

  def deals
    if  params[:range] == "10000000"
      ts_deals = Deal.filtered_url_search(
      :category => params[:category] == "all" ? nil : params[:category],
      :query => params[:q],
      :lat => params[:lat],
      :lon => params[:long],
      :range => params[:range] || Deal::MAX_RANGE,
      :age => Deal::MAX_AGE.days,
      :page => params[:page])
    else
      ts_deals = Deal.filtered_search(
      :category => params[:category] == "all" ? nil : params[:category],
      :query => params[:q],
      :lat => params[:lat],
      :lon => params[:long],
      :range => params[:range] || Deal::MAX_RANGE,
      :age => Deal::MAX_AGE.days,
      :page => params[:page])
    end
    
    @deals = Array.new
    ts_deals.map do |deal|
      if deal.hidden == false
        @deals.push deal
      end
    end
    
    puts "SEARCH DEAL COUNT:#{@deals.count}"
    options = { :minimal => true }
    options[:current_user] = current_user if current_user
    render :json => @deals.compact.as_json(options)
  end

  # example: api/search/category/:name/deals
  # required param: 
  # - params[:name]
  # optional params:
  # - params[:lat], params[:long], params[:range]
  def category
    ts_deals = Deal.filtered_search(
      :category => params[:name] == "all" ? nil : params[:name],
      :lat => params[:lat],
      :lon => params[:long],
      :range => params[:range] || Deal::MAX_RANGE,
      :age => Deal::MAX_SEARCH_AGE.days,
      :page => params[:page],
      :limit => 50)

    
    @deals = Array.new
    ts_deals.map do |deal|
      if deal.hidden == false
        @deals.push deal
      end
    end
    
    options = { :minimal => true }
    options[:current_user] = current_user if current_user
    render :json => @deals.compact.as_json(options)
  end



end