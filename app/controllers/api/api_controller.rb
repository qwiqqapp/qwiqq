class Api::ApiController < ActionController::Base
  
  respond_to :json
  
  before_filter :require_user
  
  helper_method :current_user
  
  
  # not_acceptable
  rescue_from Facebook::InvalidAccessTokenError do |e|
    notify_airbrake(e)
    Rails.logger.error "Facebook::InvalidAccessTokenError: #{e.message}"
    render :json => {:message => "Facebook::InvalidAccessTokenError: #{e.message}" }, :status => 406
  end
  
  # Method Not Allowed
  # comment this out when debugging API
  rescue_from NoMethodError do |e|
    notify_airbrake(e)
    Rails.logger.error "ApplicationController: NoMethodError #{e.message}"
    render :json => {:message => "Method Not Allowed: #{e.message}" }, :status => 405
  end
  
  # Not Found
  rescue_from ActiveRecord::RecordNotFound do |e|
    notify_airbrake(e)
    Rails.logger.error "ApplicationController: ActiveRecord::RecordNotFound #{e.message}"
    render :json => {:message => 'Not Found' }, :status => 404
  end
  
  # Bad request
  rescue_from ActiveRecord::RecordInvalid do |e|
    notify_airbrake(e)
    Rails.logger.error "ApplicationController: ActiveRecord::RecordInvalid #{e.message}"
    render :json => {:message => 'Bad Request' }, :status => 400
  end
  
  def require_user
    render :json => {:message  => 'Not Authorized'}, :status => 401 unless current_user
  end

  # this has to be a public method so that caching lambdas can access it
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def find_user(id)
    id == "current" ? current_user : User.find(id)
  end

  def paginate(collection)
    if collection.is_a? ThinkingSphinx::Search
      response.headers["X-Pages"] = collection.total_pages.to_s
      collection
    elsif params[:page]
      result = collection.page(params[:page])

      response.headers["X-Pages"] = (collection.count / result.default_per_page.to_f).ceil.to_s
      result
    else
      collection
    end
  end
end
