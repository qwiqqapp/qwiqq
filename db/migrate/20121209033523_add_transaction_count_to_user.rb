class AddTransactionCountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :transactions_count, :integer, :default => 0
    ActiveRecord::Base.connection.execute("update users set transactions_count = (select count(id) from transactions where transactions.user_id = users.id)")
  end
  def self.down
    remove_column :users, :transactions_count
  end
end
