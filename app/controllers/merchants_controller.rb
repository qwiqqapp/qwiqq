class MerchantsController < ApplicationController
  caches_action :about, :expires_in => 10.minutes
  caches_action :download, :expires_in => 1.hour
  caches_action :terms, :expires_in => 1.hour
  
  layout :find_layout

  def about
    @jacks_deals = recent_deals("jack@qwiqq.me")
    @johns_deals = recent_deals("john@qwiqq.me")
  end

  def terms
  end

  def privacy
  end

  def media
    @press_links = PressLink.order("published_at DESC")
  end

  def redirect
    redirect_to params[:to] if params[:to] =~ /^qwiqq:\/\//
  end
  
  # download.qwiqq.me
  # redirect user to download
  def download
    redirect_to "http://itunes.apple.com/us/app/qwiqq/id453258253?ls=1&mt=8"
  end


  private
  def find_layout
    request.url =~ /iphone/i ? 'iphone' : 'application'
  end
    
    def recent_deals(email)
      user = User.find_by_email(email)
      user.nil? ? [] : user.deals.sorted.limit(4)
    end
end
