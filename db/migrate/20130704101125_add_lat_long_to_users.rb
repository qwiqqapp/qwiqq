class AddLatLongToUsers < ActiveRecord::Migration

  def change
    remove_column :users, :lat
    remove_column :users, :lon
    add_column :users, :lat, :integer
    add_column :users, :lon, :integer

  end
end
