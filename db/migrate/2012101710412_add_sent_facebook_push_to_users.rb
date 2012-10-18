class AddHasSentFacebookPushToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_sent_facebook_push, :boolean, :default => false
  end
end
