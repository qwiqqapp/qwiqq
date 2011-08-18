class AddIndexOnCategoryName < ActiveRecord::Migration
  def self.up
    add_index :categories, :name
  end

  def self.down
  end
end
