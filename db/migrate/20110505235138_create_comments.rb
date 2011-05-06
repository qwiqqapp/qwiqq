class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      
      t.integer :user_id
      t.integer :deal_id
      
      t.string :body  #limit to 255, twitter for comments
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
