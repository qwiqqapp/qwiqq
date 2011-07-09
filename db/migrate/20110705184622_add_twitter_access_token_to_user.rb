class AddTwitterAccessTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_access_token, :string
  end

  def self.down
    remove_column :users, :twitter_access_token
  end
end
