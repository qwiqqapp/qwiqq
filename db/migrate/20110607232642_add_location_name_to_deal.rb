class AddLocationNameToDeal < ActiveRecord::Migration
  def self.up
    add_column :deals, :location_name, :string
  end

  def self.down
    remove_column :deals, :location_name
  end
end
