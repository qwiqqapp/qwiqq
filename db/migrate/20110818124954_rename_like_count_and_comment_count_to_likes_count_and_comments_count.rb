class RenameLikeCountAndCommentCountToLikesCountAndCommentsCount < ActiveRecord::Migration
  def self.up
    remove_index :deals, [:like_count, :comment_count]
    rename_column :deals, :like_count, :likes_count
    rename_column :deals, :comment_count, :comments_count
    add_index :deals, [:likes_count, :comments_count]
  end

  def self.down
  end
end
