class RemoveApnForRails < ActiveRecord::Migration
  def self.up
    drop_table :apn_devices
    drop_table :apn_notifications
  end



end
