class DefaultsForCounts < ActiveRecord::Migration
  def self.up
    change_column_default :deals, :comment_count, 0
    change_column_default :deals, :like_count, 0
  end

  def self.down
  end
end