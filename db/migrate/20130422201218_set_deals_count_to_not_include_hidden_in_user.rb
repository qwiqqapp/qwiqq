class SetDealsCountToNotIncludeHiddenInUser < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("update users set deals_count = (select count(id) from deals where deals.hidden = 0)")
  end
#deals.user_id = users.id AND d
  def self.down
  end
end
