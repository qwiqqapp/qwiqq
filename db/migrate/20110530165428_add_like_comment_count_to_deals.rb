class AddLikeCommentCountToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :comment_count, :integer
    add_column :deals, :like_count, :integer
  end
  
  def self.down
    remove_column :deals, :like_count
    remove_column :deals, :comment_count
  end
end