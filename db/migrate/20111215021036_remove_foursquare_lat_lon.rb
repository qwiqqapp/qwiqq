class RemoveFoursquareLatLon < ActiveRecord::Migration
  def up
    @deals = Deal.where('foursquare_venue_lat is not null')
    puts "Processing #{@deals.size} Deals with venue lat/lon..."
    
    # migrate venue data
    @deals.each do |deal|
      venue_lat = deal.foursquare_venue_lat
      venue_lon = deal.foursquare_venue_lon
      
      if venue_lat && venue_lon
        puts "Updated deal #{deal.id} with #{venue_lat} and #{venue_lon}"
        deal.update_attributes(:lat => venue_lat, :lon => venue_lon)
      end
    end
    
    # remove columns
    remove_column :deals, :foursquare_venue_lat
    remove_column :deals, :foursquare_venue_lon
  end
  
  
  def down
    add_column :deals, :foursquare_venue_lat, :float
    add_column :deals, :foursquare_venue_lon, :float
  end
end