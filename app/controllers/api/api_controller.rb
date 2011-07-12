class Api::ApiController < ActionController::Base
  
  respond_to :json
  
  before_filter :require_user
  
  helper_method :current_user
  
  # Method Not Allowed
  rescue_from NoMethodError do |e|
    Rails.logger.error "ApplicationController error#405: #{e.message}"
    render :json => {:message => 'Method Not Allowed' }, :status => 405
  end
  
  # Not Found
  rescue_from ActiveRecord::RecordNotFound do |e|
    Rails.logger.error "ApplicationController error#404: #{e.message}"
    render :json => {:message => 'Not Found' }, :status => 404
  end
  
  # Bad request
  rescue_from ActiveRecord::RecordInvalid do |e|
    Rails.logger.error "ApplicationController error#400: #{e.message}"
    render :json => {:message => 'Bad Request' }, :status => 400
  end
  
  private
  def require_user
    render :json => {:message  => 'Not Authorized'}, :status => 401 unless current_user
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def find_user(id)
    id == "current" ? current_user : User.find(id)
  end
end