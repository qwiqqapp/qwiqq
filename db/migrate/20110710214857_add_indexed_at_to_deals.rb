class AddIndexedAtToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :indexed_at, :datetime
  end

  def self.down
    remove_column :deals, :indexed_at
  end
end