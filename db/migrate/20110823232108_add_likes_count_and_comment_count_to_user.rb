class AddLikesCountAndCommentCountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :likes_count, :integer, :default => 0
    add_column :users, :comments_count, :integer, :default => 0
    add_column :users, :deals_count, :integer, :default => 0
    ActiveRecord::Base.connection.execute("update users set users.comments_count = (select count(id) from comments where comments.user_id = users.id)")
    ActiveRecord::Base.connection.execute("update users set users.likes_count = (select count(id) from likes where likes.user_id = users.id)")
    ActiveRecord::Base.connection.execute("update users set users.deals_count = (select count(id) from deals where deals.user_id = users.id)")
  end

  def self.down
    remove_column :users, :likes_count
    remove_column :users, :comments_count
    remove_column :users, :deals_count
  end
end
