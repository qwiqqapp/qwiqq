class AddRepostsCountToDeal < ActiveRecord::Migration
  def self.up
    add_column :deals, :reposts_count, :integer, :default => 0
    ActiveRecord::Base.connection.execute("update deals set reposts_count = (select count(id) from reposts where reposts.deal_id = deals.id)")
  end

  def self.down
  end
end
