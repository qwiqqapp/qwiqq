class AddFoursquareVenueIdToShare < ActiveRecord::Migration
  def self.up
    add_column :shares, :foursquare_venue_id, :string
  end

  def self.down
    remove_column :shares, :foursquare_venue_id
  end
end
