class Api::CategoriesController < Api::ApiController
  
  def index
    respond_with Category.all
  end
  
  
  def show
    @category = Category.find(params[:id])
    @deals    = @category.deals
    respond_with [@category, @deals]
  end
end
