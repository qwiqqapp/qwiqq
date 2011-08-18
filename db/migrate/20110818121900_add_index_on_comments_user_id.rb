class AddIndexOnCommentsUserId < ActiveRecord::Migration
  def self.up
    add_index :comments, :user_id
  end

  def self.down
  end
end
