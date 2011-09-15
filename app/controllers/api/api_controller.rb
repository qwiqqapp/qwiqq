class Api::ApiController < ActionController::Base
  
  respond_to :json
  
  before_filter :require_user
  
  helper_method :current_user
  
  # Method Not Allowed
  # comment this out when debugging API
  rescue_from NoMethodError do |e|
    notify_airbrake(e)
    Rails.logger.error "ApplicationController error#405: #{e.message}"
    render :json => {:message => "Method Not Allowed: #{e.message}" }, :status => 405
  end
  
  # Not Found
  rescue_from ActiveRecord::RecordNotFound do |e|
    notify_airbrake(e)
    Rails.logger.error "ApplicationController error#404: #{e.message}"
    render :json => {:message => 'Not Found' }, :status => 404
  end
  
  # Bad request
  rescue_from ActiveRecord::RecordInvalid do |e|
    notify_airbrake(e)
    Rails.logger.error "ApplicationController error#400: #{e.message}"
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


end
