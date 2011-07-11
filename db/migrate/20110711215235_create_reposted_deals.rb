class CreateRepostedDeals < ActiveRecord::Migration
  def self.up
    create_table :reposted_deals do |t|
      t.references :user, :null => false
      t.references :deal, :null => false
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :reposted_deals
  end
end
