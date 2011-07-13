class RemoveLocationIdFromDeals < ActiveRecord::Migration
  def self.up
    remove_column :deals, :location_id
  end

  def self.down
    add_column :deals, :location_id, :integer
  end
end
