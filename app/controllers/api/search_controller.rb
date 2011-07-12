class Api::SearchController < Api::ApiController

  # api/search/users
  def users
  end
  
  # api/search/deals          << considered like current, a symlink to default
  # api/search/deals/:newest
  # api/search/deals/:nearby
  # api/search/deals/:popular
  def deals
  end
  
  # api/search/category/:name/deals
  def category
  end

end