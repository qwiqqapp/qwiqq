class AddSocialyzer < ActiveRecord::Migration
  def change
    add_column :users, :socialyzer_enabled_at, :datetime
    add_column :users, :twitter_utc_offset, :integer
    add_column :users, :socialyzer_times, :text # serialized hash
  end
end
