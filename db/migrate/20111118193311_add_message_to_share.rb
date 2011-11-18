class AddMessageToShare < ActiveRecord::Migration
  def self.up
    add_column :shares, :message, :string
  end

  def self.down
    remove_column :shares, :message
  end
end

