class AddEmailToTransactions < ActiveRecord::Migration
    
  def self.up
    add_column :transactions, :email, :string, :default => ''
  end
  def self.down
  end

end
