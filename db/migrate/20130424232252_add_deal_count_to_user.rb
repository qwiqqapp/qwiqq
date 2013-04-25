class AddDealCountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :deals_count, :integer, :default => 0
  end
  def self.down
  end
end
