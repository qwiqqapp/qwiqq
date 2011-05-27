class CreateLikes < ActiveRecord::Migration
  def self.up
    create_table :likes do |t|
      t.integer :deal_id
      t.integer :user_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :likes
  end
end
