class AddNotificationSentAt < ActiveRecord::Migration
  def self.up
    add_column :likes, :notification_sent_at, :datetime
    add_column :comments, :notification_sent_at, :datetime
    add_column :relationships, :notification_sent_at, :datetime
  end
  
  def self.down
    remove_column :relationships, :notification_sent_at
    remove_column :comments, :notification_sent_at
    remove_column :likes, :notification_sent_at
  end
end