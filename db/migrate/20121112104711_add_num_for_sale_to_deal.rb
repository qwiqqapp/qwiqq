class AddNumForSaleToDeal < ActiveRecord::Migration
  def change
    remove_column :deals, :num_for_sale, :integer, :default => 0
  end
end
