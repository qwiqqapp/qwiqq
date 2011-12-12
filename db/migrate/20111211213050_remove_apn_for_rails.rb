class RemoveApnForRails < ActiveRecord::Migration
  def self.change
    drop_table :apn_devices
    drop_table :apn_notifications
  end



end
