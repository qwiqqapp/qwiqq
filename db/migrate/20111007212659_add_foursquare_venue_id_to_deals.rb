class AddFoursquareVenueIdToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :foursquare_venue_id, :string
  end

  def self.down
  end
end
