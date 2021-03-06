class Api::DealsController < Api::ApiController
  require 'rubygems'
  require 'rufus/scheduler'
    
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
  
  def available
    puts "AVAILABLE TEST"
    @deal ||= Deal.find(params[:id])
    json = {
      :amount_left        => @deal.num_left_for_sale
    }
    render :json => json
  end
  
  def popular
    @deals = Deal.unscoped.public.order("likes_count desc, comments_count desc").limit(64)
    options = { :minimal => true }
    options[:current_user] = current_user if current_user
    render :json => @deals.as_json(options)
  end
  
  # ------------------
  # public scope
  
  def feed
    #feedlets are already connected upon share, as to who can see them at that point in time?
    #limit was 40 - possibly should be changed to 120?
    @feedlets = current_user.feedlets.includes(:deal).limit(300).order("feedlets.timestamp DESC")
    render :json => paginate(@feedlets).map {|f| f.as_json(:minimal => true, :current_user => current_user) }.compact
  end
  
  def show
    find_deal
    render :json => @deal.as_json(:current_user => current_user)
  end
  
  # return deals for a given user
  # or return []
  def index      
    @deals = requested_user.deals.sorted.public
    respond_with paginate(@deals)
  end
  
  # -----------------
  # scoped to user

  # TODO move this logic to model once finalized
  # TODO this will fail if no connection to redis is available
  def create
    category = Category.find_by_name(params[:deal][:category_name])
    @deal = Deal.new(params[:deal])
    @previous_deal = current_user.deals.sorted.first
    create_deal = false
    if @previous_deal.nil?
      create_deal = true
    else 
      unless @deal.name == @previous_deal.name && @deal.foursquare_venue_id == @previous_deal.foursquare_venue_id && category == @previous_deal.category && @deal.price == @previous_deal.price
        create_deal = true
      end
    end
    if create_deal
      puts 'create deal'
      @deal.category = category
      @deal.user = current_user
      puts "DEAL PRICE:#{@deal.price} WITH:#{@deal.price.to_f/100}"
      if @deal.price.to_f/100.0 < 0.51
        @deal.for_sale_on_paypal = false 
        @deal.num_for_sale = 0
        @deal.num_left_for_sale = 0
      end
      @deal.save
      current_user.deals_num = current_user.deals_num + 1
      current_user.save!
      #In 30 DAYS check to see if user has shared
      scheduler = Rufus::Scheduler.start_new
      #original current_user.deals_num should be out of scope, so we store it
      original_deal_count = current_user.deals_num
      scheduler.every '30d' do |job|
        if @deal == current_user.deals.sorted[0] && original_deal_count >= current_user.deals_num
          #user hasn't shared in past 30 days, send out missed email
          #current user in 30 days, not current_user now
          if current_user.send_notifications 
            Mailer.missed_email(current_user).deliver
          end
        else
          #user has shared in past 30 days
          job.unschedule
        end
      end
      respond_with @deal
    else
      puts 'respond with previous deal'
      respond_with @previous_deal
    end
  end

  def update
    @deal = current_user.deals.find(params[:id])
    puts "TEST update users api"
    @deal.update_attributes(params[:deal])
    respond_with @deal
  end

  def destroy
    @deal = current_user.deals.find(params[:id])
    @deal.hidden = true
    @deal.save!
    current_user.count_posts
    current_user.save!
    render :nothing => true
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
