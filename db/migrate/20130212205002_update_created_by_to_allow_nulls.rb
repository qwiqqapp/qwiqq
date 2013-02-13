class UpdateCreatedByToAllowNulls < ActiveRecord::Migration
  def self.up
    change_column :user_events, :user_id, :integer, :null => true
    change_column :user_events, :created_by_id, :integer, :null => true
    change_column :user_events, :created_by_photo, :string, :null => true
    change_column :user_events, :created_by_photo_2x, :string, :null => true
    change_column :user_events, :created_by_username, :string, :null => true

end

  def self.down
    change_column :user_events, :user_id, :integer, :null => false
    change_column :user_events, :created_by_id, :integer, :null => false
    change_column :user_events, :created_by_photo, :string, :null => false
    change_column :user_events, :created_by_photo_2x, :string, :null => false
    change_column :user_events, :created_by_username, :string, :null => false
  end
end
