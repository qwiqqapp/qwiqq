class AddIndexOnPaypalTransactionId < ActiveRecord::Migration
  def self.up
    add_index :transactions, :paypal_transaction_id, :unique => true
  end

  def self.down
  end
end
