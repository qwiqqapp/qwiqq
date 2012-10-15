class AddFbidToUsers < ActiveRecord::Migration
  def change
    add_column :user, :fbid, :string
  end
end
