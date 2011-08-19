class RemoveRepostedDeals < ActiveRecord::Migration
  def self.up
    drop_table :reposted_deals
  end

  def self.down
  end
end
