class AddEventsHiddenToDeal < ActiveRecord::Migration

  def change
    add_column :deals, :events_hidden, :boolean, :default => false
  end
end
