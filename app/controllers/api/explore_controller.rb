# notes
# unable to use search on users and models as ActiveAdmin 
# has poluted the app with its meta search implementation

class Api::ExploreController < Api::ApiController

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
  
  # path: api/search/deals/nearby
  # path: api/search/deals
  # required params:
  # - params[:lat], params[:long], params[:range]
  # optional params
  # - params[:q]
  # - params[:category]

  def deals
    puts "category:#{params[:category]}"
    puts "query:#{params[:q]}"
    puts "lat:#{params[:lat]}"
    puts "long:#{params[:long]}"
    puts "range:#{params[:range]}"
    puts "page:#{params[:page]}"
    
    if  params[:range] == "10000000"
      @deals = Deal.filtered_url_search(
      :category => params[:category] == "all" ? nil : params[:category],
      :query => params[:q],
      :lat => params[:lat],
      :lon => params[:long],
      :range => params[:range] || Deal::MAX_RANGE,
      :age => Deal::MAX_AGE.days,
      :page => params[:page])
    else
      @deals = Deal.filtered_search(
      :category => params[:category] == "all" ? nil : params[:category],
      :query => params[:q],
      :lat => params[:lat],
      :lon => params[:long],
      :range => params[:range] || Deal::MAX_RANGE,
      :age => Deal::MAX_AGE.days,
      :page => params[:page])
    end
    
    puts "SEARCH DEAL COUNT:#{@deals.count}"
    options = { :minimal => true }
    options[:current_user] = current_user if current_user
    render :json => paginate(@deals).compact.as_json(options)
  end  
    
   def deals_test
    puts "TEST EXPLORE - deals test"
    
    a = []
    b =  [9,10]
    a1 = [a,b]

    puts "TEST ARRAY:#{a1}"
    a1 = a1.flatten
    puts "FLATTEN A1:#{a1}"



    @users = User.search(params[:q])
    puts "SEARCH USERS COUNT:#{@users.count}"
    user_deals = Array.new
    
    @users.map do |user|
      puts "user deals:#{user.deals}"
     user.deals.map do |deal|
       user_deals.push deal
     end
    end


    query_deals = Array.new  
    puts "MAP TEST DEALS:#{@deals}"
    puts "category:#{params[:category]}"
    puts "query:#{params[:q]}"
    puts "lat:#{params[:lat]}"
    puts "long:#{params[:long]}"
    puts "range:#{params[:range]}"
    puts "page:#{params[:page]}"
    
    if  params[:range] == "10000000"
      query_deals = Deal.filtered_url_search(
      :category => params[:category] == "all" ? nil : params[:category],
      :query => params[:q],
      :lat => params[:lat],
      :lon => params[:long],
      :range => params[:range] || Deal::MAX_RANGE,
      :page => params[:page])
    else
      query_deals = Deal.filtered_search(
      :category => params[:category] == "all" ? nil : params[:category],
      :query => params[:q],
      :lat => params[:lat],
      :lon => params[:long],
      :range => params[:range] || Deal::MAX_RANGE,
      :page => params[:page])
    end
    query_deals = [query_deals[0], query_deals[1]]
    @deals = [user_deals, query_deals]
    puts "BEFORE EXPLORE TEST DEALS:#{@deals}"
    puts ""
    puts ""
    puts ""
    puts ""
    puts ""
    puts ""

    
    @deals = @deals.flatten
    puts "FLATTEN EXPLORE TEST DEALS:#{@deals} - This isn't working for nil user_deals"
    
    @deals = @deals.uniq.compact
    puts "EXPLORE TEST DEALS:#{@deals}"


    options = { :minimal => true }
    options[:current_user] = current_user if current_user
    render :json => paginate(@deals).compact.as_json(options)
  end  
    
  def test
    #if  params[:range] == "10000000"
    #  puts "GLOBAL SEARCH"
    #  @deals = Deal.filtered_test_search(
    #  :category => params[:category] == "all" ? nil : params[:category],
    #  :query => params[:q],
    #  :lat => params[:lat],
    #  :lon => params[:long],
    #  :range => params[:range] || Deal::MAX_RANGE,
    #  :age => Deal::MAX_AGE.days,
    #  :page => params[:page])
   # else
    #  @deals = Deal.filtered_search_3_0(
    #  :category => params[:category] == "all" ? nil : params[:category],
    #  :query => params[:q],
    #  :lat => params[:lat],
    #  :lon => params[:long],
    #  :range => params[:range] || Deal::MAX_RANGE,
    #  :age => Deal::MAX_AGE.days,
    #  :page => params[:page])
    #end
    
    #puts "SEARCH DEAL COUNT:#{@deals.count}"
    #options = { :minimal => true }
    #options[:current_user] = current_user if current_user
    #render :json => paginate(@deals).compact.as_json(options)
  end
  
  def popular
    @deals = Deal.scoped.recent.sorted
    puts @deals.count
    options = { :minimal => true }
    options[:current_user] = current_user if current_user
    result = @deals.page(params[:page])
    string = (@deals.count / result.default_per_page.to_f).ceil.to_s
    response.headers["X-Total-Pages"] = string
    render :json => paginate(@deals).compact.as_json(options)
  end

  # example: api/search/category/:name/deals
  # required param: 
  # - params[:name]
  # optional params:
  # - params[:lat], params[:long], params[:range]
  def category
    @deals = Deal.filtered_search(
      :category => params[:name] == "all" ? nil : params[:name],
      :lat => params[:lat],
      :lon => params[:long],
      :range => params[:range] || Deal::MAX_RANGE,
      :age => Deal::MAX_AGE.days,
      :page => params[:page])

    
    #userm = User.find_by_email("mscaria@novationmobile.com")
    #Mailer.weekly_update(userm, @deals).deliver
    
    options = { :minimal => true }
    options[:current_user] = current_user if current_user
    render :json => paginate(@deals).compact.as_json(options)
  end
end