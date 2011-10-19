class AddFoursquareVenueNameToDeal < ActiveRecord::Migration
  def self.up
    add_column :deals, :foursquare_venue_name, :string
  end

  def self.down
    remove_column :deals, :foursquare_venue_name
  end
end
