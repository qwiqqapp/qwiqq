class Admin::AdminController < ActionController::Base
  
  layout 'admin'
  before_filter :require_admin
  
  private
  def require_admin
    authenticate_or_request_with_http_basic do |username, password|
      username == "canucks" && password == "texasbbq"
    end
  end
end