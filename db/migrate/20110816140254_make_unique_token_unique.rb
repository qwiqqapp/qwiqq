class MakeUniqueTokenUnique < ActiveRecord::Migration
  def self.up
    add_index :deals, :unique_token, :unique => true
  end

  def self.down
  end
end
