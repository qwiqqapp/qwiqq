class Admin::DealsController < Admin::AdminController
  
  before_filter :load_categories
  
  def index    
    if params[:category_name]
      @deals = Category.find_by_name(params[:category_name]).deals
      @title = "#{@deals.size} #{params[:category_name].titleize} Deals"
    else
      @deals = Deal.limit(50).order(:created_at => 'desc')
      @title = "50 Recent Deals"
    end
  end
  
  def show
    @deal = Deal.find(params[:id])
  end
  
  private
  def load_categories
    @categories ||= Category.all.map{|c| [c.name, c.deals.size] }
  end
end