class AddIndexesOnLikes < ActiveRecord::Migration
  def self.up
    add_index :likes, :user_id
    add_index :likes, :deal_id
  end

  def self.down
  end
end
