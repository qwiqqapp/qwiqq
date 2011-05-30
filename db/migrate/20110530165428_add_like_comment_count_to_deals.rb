class AddLikeCommentCountToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :comment_count, :integer
    add_column :deals, :like_count, :integer
    
    Deal.reset_column_information
    
    Deal.all.each do |d|
      d.comment_count = rand(20)
      d.like_count = rand(100)
      d.save!
    end
  end
  
  def self.down
    remove_column :deals, :like_count
    remove_column :deals, :comment_count
  end
end