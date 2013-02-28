class ApplicationController < ActionController::Base
  protect_from_forgery
   
  respond_to :html, :json
  helper_method :ios?
  
  
  
  def ios?
    !!(request.env['HTTP_USER_AGENT'] =~ /iPhone/i)
  end
  
  unless Rails.env.production?
    
    ENV['FLYING_SPHINX_API_KEY'] = "22c734e05651f1426"
    ENV['FLYING_SPHINX_HOST'] = "ec2-23-22-6-59.compute-1.amazonaws.com"
    ENV['FLYING_SPHINX_IDENTIFIER'] = "597057379d51d3f77"
    ENV['FLYING_SPHINX_INGRESS'] = "true"
    ENV['FLYING_SPHINX_PORT'] = "9352"
    
    ENV['S3_BUCKET'] = "qwiqq.images.production"
    ENV['S3_KEY'] = "AKIAJOMG7WLZJME47VDQ"
    ENV['S3_SECRET'] = "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"
  end
  
end
