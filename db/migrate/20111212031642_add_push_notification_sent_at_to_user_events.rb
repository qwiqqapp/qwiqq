class AddPushNotificationSentAtToUserEvents < ActiveRecord::Migration
  def self.up
    add_column :user_events, :push_notification_sent_at, :datetime
  end

  def self.down
    remove_column :user_events, :push_notification_sent_at
  end
end