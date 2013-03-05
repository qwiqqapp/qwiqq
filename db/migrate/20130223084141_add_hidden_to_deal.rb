class AddHiddenToDeal < ActiveRecord::Migration

  def change
    add_column :deals, :hidden, :boolean, :default => false
  end
end
