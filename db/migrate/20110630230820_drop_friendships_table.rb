class DropFriendshipsTable < ActiveRecord::Migration
  def self.up
    drop_table :friendships rescue nil
  end
end
