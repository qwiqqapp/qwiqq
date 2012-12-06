class RemoveBuyerIdFromDeals < ActiveRecord::Migration
  def up
    remove_column :deals, :buyer_id, :integer
  end
    
  def down
    add_column :deals, :buyer_id, :integer
  end
end
