class RemoveSharedAtFieldsFromDeal < ActiveRecord::Migration
  def self.up
    remove_column :deals, :shared_to_twitter_at
    remove_column :deals, :shared_to_facebook_at
  end

  def self.down
    add_column :deals, :shared_to_facebook_at, :datetime
    add_column :deals, :shared_to_twitter_at, :datetime
  end
end
