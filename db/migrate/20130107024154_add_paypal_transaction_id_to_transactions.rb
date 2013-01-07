class AddPaypalTransactionIDToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :paypal_transaction_id, :integer, :unique => true
  end
  def self.down
    remove_column :transactions, :paypal_transaction_id
  end
end
