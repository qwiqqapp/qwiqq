class UpdateLocationsFloatsToDoubles < ActiveRecord::Migration
  def self.up
    rename_column :locations, :long, :lon
    change_column :locations, :lat, :float8
    change_column :locations, :lon, :float8
  end

  def self.down
  end
end
