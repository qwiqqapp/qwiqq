class DropFriendshipsTable < ActiveRecord::Migration
  def self.up
    # This causes an error when populating a fresh DB
    drop_table :friendships rescue nil
  end
end
