class AddNotificationsTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :notifications_token, :string

    # update existing users
    User.all.each {|u| u.save }
  end

  def self.down
    remove_column :users, :notifications_token
  end
end
