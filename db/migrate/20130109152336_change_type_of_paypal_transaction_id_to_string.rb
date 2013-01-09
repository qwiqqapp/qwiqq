class ChangeTypeOfPayPalTransactionIdToString < ActiveRecord::Migration
  def self.up
    change_column :transactions, :paypal_transaction_id, :string
  end

  def self.down
    change_column :transactions, :paypal_transaction_id, :integer
  end
end
