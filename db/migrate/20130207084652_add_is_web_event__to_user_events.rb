class AddIsWebEventToUserEvents < ActiveRecord::Migration
  def self.up
    add_column :user_events, :is_web_event, :boolean, :default => false
  end

  def self.down
    remove_column :user_events, :is_web_event
  end
end