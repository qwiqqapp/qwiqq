class UpdateLocationsFloatsToDoubles < ActiveRecord::Migration
  def self.up
    rename_column :locations, :long, :lon
    change_column :locations, :lat, :double
    change_column :locations, :lon, :double
  end

  def self.down
  end
end
