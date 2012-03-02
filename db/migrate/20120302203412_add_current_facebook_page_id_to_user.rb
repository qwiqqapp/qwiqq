class AddCurrentFacebookPageIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :current_facebook_page_id, :string
  end
end
