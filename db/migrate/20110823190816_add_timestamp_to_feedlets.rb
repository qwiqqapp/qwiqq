class AddTimestampToFeedlets < ActiveRecord::Migration
  def self.up
    remove_index :feedlets, :created_at
    add_column :feedlets, :timestamp, :timestamp
    add_index :feedlets, :created_at
  end

  def self.down
  end
end
