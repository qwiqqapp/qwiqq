class HomeController < ApplicationController
  layout :pick_layout
  helper_method :iphone?
  
  def about
    @jacks_deals = recent_deals("jack@qwiqq.me")
    @johns_deals = recent_deals("john@qwiqq.me")
  end

  def terms
  end

  def privacy
  end

  def download
    redirect_to "http://store"
  end

  private
    def recent_deals(email)
      user = User.find_by_email(email)
      user.nil? ? [] : user.deals.limit(3)
    end

    def iphone?
      @iphone
    end

    def pick_layout
      @iphone = request.path =~ /iphone/
      @iphone ? "iphone" : "application"
    end
end
