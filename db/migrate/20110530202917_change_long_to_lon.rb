class ChangeLongToLon < ActiveRecord::Migration
  def self.up
    rename_column :deals, :long, :lon
    
    change_column :deals, :lat, :float8
    change_column :deals, :lon, :float8
  end

  def self.down
  end
end