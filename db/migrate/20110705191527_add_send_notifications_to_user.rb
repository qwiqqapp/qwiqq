class AddSendNotificationsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :send_notifications, :boolean, :default => true

    #User.all.each do |user|
    #  user.update_attribute(:send_notifications, true)
    #end
  end

  def self.down
    remove_column :users, :send_notifications
  end
end
