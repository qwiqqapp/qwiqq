class AddReadToUserEvent < ActiveRecord::Migration
  def self.up
    add_column :user_events, :read, :boolean, :default => false
  end

  def self.down
    remove_column :user_events, :read
  end
end
