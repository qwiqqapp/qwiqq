class AddUserCountsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :followers_count, :int, :default => 0
    add_column :users, :following_count, :int, :default => 0
    add_column :users, :friends_count, :int, :default => 0
  end

  def self.down
    remove_column :users, :friends_count
    remove_column :users, :following_count
    remove_column :users, :followers_count
  end
end
