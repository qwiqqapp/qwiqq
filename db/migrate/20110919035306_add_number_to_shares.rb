class AddNumberToShares < ActiveRecord::Migration
  def self.up
    add_column :shares, :number, :string
  end

  def self.down
  end
end
