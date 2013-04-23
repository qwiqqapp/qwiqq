class SetDealsCountToNotIncludeHiddenInUser < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("update users set deals_count = (select count(id) from deals where deals.user_id = users.id AND deals.hidden = 0)")
  end

  def self.down
  end
end
