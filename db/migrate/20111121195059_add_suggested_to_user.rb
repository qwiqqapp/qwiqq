class AddSuggestedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :suggested, :boolean, :default => false
  end

  def self.down
    remove_column :users, :suggested
  end
end
