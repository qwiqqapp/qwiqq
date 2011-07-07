class CreateShares < ActiveRecord::Migration
  def self.up
    create_table :shares do |t|
      t.references :user
      t.references :deal
      t.string :service, :null => false
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :shares
  end
end
