#class AddNumForSaleToDeal < ActiveRecord::Migration
class RemoveNumForSale < ActiveRecord::Migration

  def change
    #add_column :deals, :num_for_sale, :integer, :default => 0
    remove_column :deals, :num_for_sale

  end
end
