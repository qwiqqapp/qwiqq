class SetDealsCountToNotIncludeHiddenInUser < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("update users set deals_count = (select count(id) from deals where not deals.hidden)")
  end
#deals.user_id = users.id and 
  def self.down
  end
end
