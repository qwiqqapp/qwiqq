class AddNumLeftForSaleToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :num_left_for_sale, :integer, :default => 0
  end
end
