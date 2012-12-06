class RemoveBuyerIdFromTransactions < ActiveRecord::Migration
  def up
    remove_column :transactions, :buyer_id
  end
    
  def down
    add_column :transactions, :buyer_id, :integer
  end
end
