class AddVenueCoordsToDeal < ActiveRecord::Migration
  def self.up
    add_column :deals, :foursquare_venue_lat, :float
    add_column :deals, :foursquare_venue_lon, :float
  end

  def self.down
    remove_column :deals, :foursquare_venue_lat
    remove_column :deals, :foursquare_venue_lon
  end
end
