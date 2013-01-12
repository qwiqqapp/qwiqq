class AddLocatedToDeals < ActiveRecord::Migration
    
  def self.up
    add_column :deals, :located, :boolean, :default => false
  end
  def self.down
  end

end
