class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer :user_id
      t.integer :target_id
      t.timestamps
    end

    add_index :relationships, :user_id
    add_index :relationships, :target_id
    add_index :relationships, [:user_id, :target_id], :unique => true
  end

  def self.down
    drop_table :relationships
  end
end
