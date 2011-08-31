class RemoveIndexedAt < ActiveRecord::Migration
  def self.up
    # remove_column :deals, :indexed_at
  end

  def self.down
    add_column :deals, :indexed_at, :datetime
  end
end
