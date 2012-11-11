class AddNumForSaleToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :num_for_sale, :integer, :default => 0
  end
end
