class Api::UsersController < Api::ApiController
  require 'rubygems'
  require 'rufus/scheduler'
  
  skip_before_filter :require_user, :only => [:create, :show, :followers, :following, :friends]

  #  broken
  # caches_action :show, :cache_path => lambda {|c|
  #   (c.current_user.try(:cache_key) || "guest") + "/" + c.requested_user.try(:cache_key)
  # } # expires automatically when users cache key changes or deals cache key changes

  # caches_action :followers, :cache_path => lambda {|c| "followers/#{c.requested_user.cache_key}" },
  #   :unless => lambda {|c| c.params[:page] }
  # 
  # caches_action :following, :cache_path => lambda {|c| "following/#{c.requested_user.cache_key}" },
  #   :unless => lambda {|c| c.params[:page] }
  

  def requested_user
    @user ||= find_user(params[:id])
  end

  # will raise RecordNotFound if user not found
  # will render 401 if email does not match
  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
    end
    
    
    #email notifications
    Mailer.welcome_email(@user).deliver
    scheduler = Rufus::Scheduler.start_new
   
    #check if user has created profile in 1 day
    user_email = @user.email
      scheduler.every '1w' do |job|
        user = User.find_by_email(user_email)
        return if user.nil?
        if user.country.blank? || user.photo || user.first_name.blank?
          #user hasn't created a post yet, send email
          if user.send_notifications    # only send if user has notifications enabled
            Mailer.update_profile(user).deliver
          end
          job.unschedule
        else
          #user has created a post
          job.unschedule
        end
      end
      
    #in one week check if user has posted and shared a post
    
      #check if user has created post
      scheduler.every '1w' do |job|
        if @user.deals_count == 0
          #user hasn't created a post yet, send email
          if @user.send_notification
            Mailer.create_post(@user).deliver
          end
        else
          #user has created a post
          job.unschedule
        end
      end

      #check if user has shared
      scheduler.every '1w' do |job|
        if @user.events.count == 0
          #user hasn't shared a post yet, send email
          if @user.send_notification
            Mailer.share_post(@user).deliver
          end
        else
          #user has shared a post
          job.unschedule
        end
      end
    
    respond_with :api, @user do
      render :status => :created, :json => @user.as_json(:current_user => current_user) and return if @user.valid?
    end
  end

  # only the current user can be updated
  def update
    raise ActiveRecord::RecordNotFound unless params[:id] == "current"
    @user = current_user
    @user.update_attributes(params[:user])
    respond_with(:api, @user) do
      if @user.valid?
        render :json => @user.as_json(:current_user => current_user) and return
      end
    end
  end
  
  def show
    requested_user
    render :json => @user.as_json(
      :current_user => current_user,
      :deals => true, 
      :comments => true,
      :events => @user == current_user)
  end

  def followers
    requested_user
    @followers = @user.followers.sorted
    respond_with @followers.as_json(:current_user => current_user)
  end

  def following
    requested_user
    @following = @user.following.sorted
    puts 'following: '
    puts @following.count
    #result = @following.page(params[:page])
    #puts 'result:'
    #puts result
    #string = (@following.count / result.default_per_page.to_f).ceil.to_s
    string = '1'
    #create custom x- response header data to transfer the number of pages
    response.headers["X-Total-Pages"] = string
    puts "Total number of queries needed #{string}"
    respond_with @following.as_json_min(:current_user => current_user)
  end

  def friends
    requested_user
    @friends = @user.friends
    respond_with @friends
  end

  def events
    raise ActiveRecord::RecordNotFound unless params[:id] == "current"
    @events = current_user.events
    respond_with paginate(@events)
  end

  def clear_events
    raise ActiveRecord::RecordNotFound unless params[:id] == "current"
    current_user.events.unread.clear
    render :status => 200, :nothing => true
  end

  def enable_socialyzer
    requested_user
    @user.enable_socialyzer!
    render :status => 200, :nothing => true
  end

  def disable_socialyzer
    requested_user
    @user.disable_socialyzer!
    render :status => 200, :nothing => true
  end

  def suggested
    @users = User.suggested
    respond_with @users.as_json(:current_user => current_user)
  end

  def facebook_pages
    raise ActiveRecord::RecordNotFound unless params[:id] == "current"
    @facebook_pages = current_user.facebook_client.pages.map do |page|
      { id: page["id"], name: page["name"], access_token: page["access_token"]}
    end
    respond_with @facebook_pages
  end
end

