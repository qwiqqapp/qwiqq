class Admin::LocationsController < Admin::AdminController
  
  def index
    @locations = Location.all
    @title = "#{@locations.size} Locations"
  end
  
end