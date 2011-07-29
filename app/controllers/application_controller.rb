class ApplicationController < ActionController::Base
  protect_from_forgery
   
  respond_to :html, :json


  def ios?
    !!(request.env['HTTP_USER_AGENT'] =~ /iPhone/i)
  end
end
