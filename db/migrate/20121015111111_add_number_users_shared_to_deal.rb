class AddNumberUsersSharedToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :number_users_shared, :integer, :default => 0
  end
end
