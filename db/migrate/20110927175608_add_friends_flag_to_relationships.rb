class AddFriendsFlagToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :friends, :boolean, :default => false
    add_index :relationships, :friends
    Relationship.reset_column_information
    Relationship.where("id IN (SELECT r1.id FROM relationships r1, relationships r2 WHERE r1.user_id = r2.target_id AND r1.target_id = r2.user_id)").find_each do |r| 
      r.friends = true
      r.save
    end
  end

  def self.down
  end
end
