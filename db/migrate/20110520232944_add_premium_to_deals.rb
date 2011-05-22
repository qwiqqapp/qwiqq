class AddPremiumToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :premium, :boolean, :default => false
  end
  
  def self.down
    remove_column :deals, :premium
  end
end