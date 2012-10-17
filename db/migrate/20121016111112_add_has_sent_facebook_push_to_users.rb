class AddHasSentFacebookPushToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hasSentFacebookPush, :string
  end
end
