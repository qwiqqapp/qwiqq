class AddIndexesOnLikeCountAndCommentCount < ActiveRecord::Migration
  def self.up
    add_index :deals, [ :like_count, :comment_count ]
  end

  def self.down
  end
end
