class AddHiddenToUserEvent < ActiveRecord::Migration

  def change
    add_column :user_events, :hidden, :boolean, :default => false
  end
end
