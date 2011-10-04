class AddFoursquareColumnsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :foursquare_id, :string
    add_column :users, :foursquare_access_token, :string
  end

  def self.down
    remove_column :users, :foursquare_access_token
    remove_column :users, :foursquare_id
  end
end
