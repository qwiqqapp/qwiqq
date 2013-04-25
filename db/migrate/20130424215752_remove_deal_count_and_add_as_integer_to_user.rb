class RemoveDealCountAndAddAsIntegerToUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :deals_count
    add_column :users, :deals_count, :integer, :default => 0
  end
  def self.down
  end
end
