class RemoveDealCountFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :deals_count
  end
  def self.down
  end
end
