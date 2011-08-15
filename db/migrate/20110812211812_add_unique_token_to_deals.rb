class AddUniqueTokenToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :unique_token, :string
  end

  def self.down
    remove_column :deals, :unique_token
  end
end