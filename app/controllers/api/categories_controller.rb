class Api::CategoriesController < Api::ApiController
  
  skip_before_filter :require_user
  
  def show
    @category = Category.find_by_name!(params[:name])
    @deals    = @category.deals.order("created_at desc").includes(:category)
    
    respond_with @deals
  end
end
