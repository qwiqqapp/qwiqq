class AddUserIdToApnDevices < ActiveRecord::Migration
  def self.up
    add_column :apn_devices, :user_id, :integer
    add_index :apn_devices, :user_id
  end

  def self.down
  end
end
