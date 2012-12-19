class AddSentFacebookPushToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sent_facebook_push, :boolean, :default => false
  end
end
