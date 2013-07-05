class AddLatLongToUsers < ActiveRecord::Migration

  def change
    remove_column :user, :lat
    remove_column :user, :lon
    add_column :users, :lat, :integer
    add_column :users, :lon, :integer

  end
end
