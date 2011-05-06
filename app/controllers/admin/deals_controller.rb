class Admin::DealsController < Admin::AdminController
  
  before_filter :load_categories
  
  def index    
    if params[:category_name]
      @deals = Category.find_by_name(params[:category_name]).deals
      @title = "#{@deals.size} #{params[:category_name].titleize} Deals"
    else
      @deals = Deal.all
      @title = "All #{@deals.size} Deals"
    end
  end
  
  
  private
  def load_categories
    @categories = Category.all.map(&:name)
  end
end