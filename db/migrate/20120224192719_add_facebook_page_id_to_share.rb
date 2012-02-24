class AddFacebookPageIdToShare < ActiveRecord::Migration
  def change
    add_column :shares, :facebook_page_id, :string
  end
end
