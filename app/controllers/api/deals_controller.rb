class Api::DealsController < Api::ApiController
  
  skip_before_filter :require_user, :only => [:popular, :show, :index]
  caches_action :popular, :expires_in => 10.minutes
  caches_action :show, :cache_path => lambda {|c|
    (c.current_user.try(:cache_key) || "guest") + "/" + c.find_deal.cache_key
  } # expires automatically when users cache key changes or deals cache key changes

  caches_action :index, :cache_path => lambda {|c| "#{requested_user.cache_key}/deals"}

  def find_deal
    @deal ||= Deal.find(params[:id])
  end

  def requested_user
    @user ||= find_user(params[:user_id])
  end

  # ------------------
  # no auth required
  def popular
    @deals = Deal.unscoped.order("likes_count desc, comments_count desc").limit(64)
    render :json => @deals.as_json(:minimal => true)
  end
  
  # ------------------
  # public scope
  
  def feed
    @feedlets = current_user.feedlets.includes(:deal).limit(40).order("feedlets.timestamp DESC")


    render :json => @feedlets.map {|f| f.as_json(:minimal => true) }.compact
  end
  
  def show
    find_deal
    # i.e. :include => [ :comments, :liked_by_users ]
    render :json => @deal.as_json(:current_user => current_user,
                                  :comments => true, 
                                  :liked_by_users => true)
  end
  
  
  # return deals for a given user
  # or return []
  def index      
    @deals = requested_user.deals.sorted
    respond_with @deals
  end
  
  # -----------------
  # scoped to user

  # TODO move this logic to model once finalized
  def create
    category = Category.find_by_name(params[:deal][:category_name])
    @deal = Deal.new(params[:deal])
    @deal.category = category
    @deal.user = current_user
    @deal.save
    respond_with @deal
  end

  def update
    @deal = current_user.deals.find(params[:id])
    @deal.update_attributes(params[:deal])
    respond_with @deal
  end

  def repost
    @deal = Deal.find(params[:id])
    @user = find_user(params[:user_id])
    @reposted_deal = @user.repost_deal!(@deal)
    respond_with @reposted_deal, :location => false
  end

  def destroy
    @deal = current_user.deals.find(params[:id])
    @deal.destroy
    respond_with @deal
  end

end
