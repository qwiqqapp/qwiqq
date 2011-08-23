class CreateFeedlets < ActiveRecord::Migration
  def self.up
    create_table :feedlets do |t|
      t.integer :deal_id
      t.integer :user_id
      t.string :reposted_by
      t.timestamp :created_at
      t.integer :posting_user_id
    end

    add_index :feedlets, :user_id
    add_index :feedlets, :created_at
    add_index :feedlets, :posting_user_id
  end

  def self.down
    drop_table :feedlets
  end
end
