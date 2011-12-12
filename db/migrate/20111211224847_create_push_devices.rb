class CreatePushDevices < ActiveRecord::Migration
  def self.up
    create_table :push_devices, :force => true do |t|
      t.string :token, :size => 100, :null => false
      t.integer :user_id
      t.datetime :last_registered_at
      
      t.timestamps
    end
    
    add_index :push_devices, :token, :unique => true
  end
  
  def self.down
    drop_table :push_devices
  end
end
