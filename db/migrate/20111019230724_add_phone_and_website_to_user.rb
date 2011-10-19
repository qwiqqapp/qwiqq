class AddPhoneAndWebsiteToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :phone, :string
    add_column :users, :website, :string
  end

  def self.down
    remove_column :users, :website
    remove_column :users, :phone
  end
end
