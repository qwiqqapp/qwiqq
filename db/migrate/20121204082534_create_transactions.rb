class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :paypal_transaction_id
      t.integer :deal_id
      t.integer :buyer_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
