class AddSharedAtFieldsToDeal < ActiveRecord::Migration
  def self.up
    add_column :deals, :shared_to_facebook_at, :datetime
    add_column :deals, :shared_to_twitter_at, :datetime
  end

  def self.down
    remove_column :deals, :shared_to_twitter_at
    remove_column :deals, :shared_to_facebook_at
  end
end
