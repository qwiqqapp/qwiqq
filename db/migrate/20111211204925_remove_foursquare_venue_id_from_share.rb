class RemoveFoursquareVenueIdFromShare < ActiveRecord::Migration
  def self.up
    remove_column :shares, :foursquare_venue_id
  end

  def self.down
    add_column :shares, :foursquare_venue_id, :string
  end
end
