class CreateReposts < ActiveRecord::Migration
  def self.up
    create_table :reposts do |t|
      t.integer :user_id
      t.integer :deal_id

      t.timestamps
    end

    add_index :reposts, :user_id
  end

  def self.down
    drop_table :reposts
  end
end
