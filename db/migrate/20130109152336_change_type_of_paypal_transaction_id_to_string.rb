class ChangeTypeOfPayPalTransactionIdToString < ActiveRecord::Migration
  def self.up
    change_column :transactions, :paypal_transaction_id, :string
  end

  def self.down
  end
end
