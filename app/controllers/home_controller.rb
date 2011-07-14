class HomeController < ApplicationController
  def about
  end

  def terms
  end

  def privacy
  end

  def download
    redirect_to "http://store"
  end
end
