class AddLatLongToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :lat, :float
    add_column :deals, :long, :float
  end

  def self.down
    remove_column :deals, :long
    remove_column :deals, :lat
  end
end