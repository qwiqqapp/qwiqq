class AddIndexOnDealsUserId < ActiveRecord::Migration
  def self.up
    add_index :deals, :user_id
  end

  def self.down
  end
end
