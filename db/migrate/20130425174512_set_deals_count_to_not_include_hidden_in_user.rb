class SetDealsCountToNotIncludeHiddenInUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :deals_count
    add_column :users, :deals_num, :integer, :default => 0
    ActiveRecord::Base.connection.execute("update users set deals_num = (select count(id) from deals where deals.user_id = users.id and not deals.hidden)")
  end
  def self.down
  end
end
