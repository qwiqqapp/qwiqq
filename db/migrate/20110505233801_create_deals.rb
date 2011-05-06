class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.string  :name
      t.integer :price
      t.integer :percent
      
      t.integer :user_id
      t.integer :location_id 
      t.integer :category_id

      t.timestamps
    end
  end

  def self.down
    drop_table :deals
  end
end
