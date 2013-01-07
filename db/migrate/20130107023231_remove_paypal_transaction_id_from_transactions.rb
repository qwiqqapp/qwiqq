class RemovePaypalTransactionIdFromTransactions < ActiveRecord::Migration
  def up
    # remove columns
    remove_column :transactions, :paypal_transaction_id
  end
  
  
  def down
    add_column :transactions, :paypal_transaction_id, :integer
  end
end