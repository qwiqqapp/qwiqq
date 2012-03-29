class Api::DealsController < Api::ApiController
  
  skip_before_filter :require_user, :only => [:popular, :show, :index]
  caches_action :popular, :expires_in => 10.minutes
  caches_action :show, :cache_path => lambda {|c|
    (c.current_user.try(:cache_key) || "guest") + "/" + c.find_deal.cache_key
  } # expires automatically when users cache key changes or deals cache key changes

  caches_action :index, :cache_path => lambda {|c| "#{requested_user.cache_key}/deals"}, 
    :unless => lambda {|c| c.params[:page] }

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
    options = { :minimal => true }
    options[:current_user] = current_user if current_user
    render :json => @deals.as_json(options)
  end
  
  # ------------------
  # public scope
  
  def feed
    @feedlets = current_user.feedlets.includes(:deal).limit(40).order("feedlets.timestamp DESC")
    render :json => paginate(@feedlets).map {|f| f.as_json(:minimal => true, :current_user => current_user) }.compact
  end
  
  def show
    find_deal
    render :json => @deal.as_json(:current_user => current_user)
  end
  
  # return deals for a given user
  # or return []
  def index      
    @deals = requested_user.deals.sorted
    respond_with paginate(@deals)
  end
  
  # -----------------
  # scoped to user

  # TODO move this logic to model once finalized
  def create
    
    # temp check
    if params[:deal][:foursquare_venue_id].blank? && Rails.env.production?
      Rails.logger.error "DealsController#create >>>>> 4SQ_VENUE_ID is missing!"
      Rails.logger.error params.inspect
    end
    
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

  def destroy
    @deal = current_user.deals.find(params[:id])
    @deal.destroy
    respond_with @deal
  end

  def repost
    # deprecated
    render :status => :created, :nothing => true
  end

  def events
    deal = Deal.find(params[:id])
    respond_with paginate(deal.events)
  end

end
