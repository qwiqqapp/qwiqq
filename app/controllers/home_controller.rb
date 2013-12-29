class HomeController < ApplicationController
  caches_action :about, :expires_in => 10.minutes
  caches_action :download, :expires_in => 1.hour
  caches_action :terms, :expires_in => 1.hour
  
  layout :find_layout


  def about
    puts 'about'
    @jacks_deals = recent_deals('16')
    @johns_deals = recent_deals('15')
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    puts 'Jack'
    puts @jacks_deals
    puts 'John'
    puts @johns_deals
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
    
    def recent_deals(user_id)
      user = User.find(user_id)
      puts user
      user.nil? ? [] : user.deals.sorted.limit(4)
    end
end
