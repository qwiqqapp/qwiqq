class AddSendNotificationsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :send_notifications, :boolean, :default => true
  end

  def self.down
    remove_column :users, :send_notifications
  end
end
