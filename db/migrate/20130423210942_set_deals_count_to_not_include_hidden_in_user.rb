class SetDealsCountToNotIncludeHiddenInUser < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("update users set deals_count = (select count(id) from deals where deals.user_id = users.id and not deals.hidden)")
  end
  def self.down
  end
end
