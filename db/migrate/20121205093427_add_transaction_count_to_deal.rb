class AddTransactionCountToDeals < ActiveRecord::Migration
    
  def self.up
    add_column :deals, :transaction_count, :integer, :default => 0
  end
  def self.down
    remove_column :deals, :transaction_count
  end

end
