class AddSharesCountToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :shares_count, :integer, :default => 0
    ActiveRecord::Base.connection.execute("update deals set shares_count = (select count(id) from shares where shares.deal_id = deals.id)")
  end

  def self.down
  end
end
