class RenameTransactionCountToTransactionsCount < ActiveRecord::Migration
  def self.up
    rename_column :deals, :transaction_count, :transactions_count
    add_index :deals, [:transactions_count]
  end

  def self.down
  end
end
