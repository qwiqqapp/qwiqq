class CreateFeedlets < ActiveRecord::Migration
  def self.up
    create_table :feedlets do |t|
      t.integer :deal_id
      t.integer :user_id
      t.string :reposted_by
      t.timestamp :created_at
    end

    add_index :feedlets, :user_id
    add_index :feedlets, :created_at
  end

  def self.down
    drop_table :feedlets
  end
end
