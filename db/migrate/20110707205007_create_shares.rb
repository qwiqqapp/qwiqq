class CreateShares < ActiveRecord::Migration
  def self.up
    create_table :shares do |t|
      t.references :user, :null => false
      t.references :deal, :null => false
      t.string :service, :null => false
      t.string :email
      t.datetime :created_at
      t.datetime :shared_at
    end
  end

  def self.down
    drop_table :shares
  end
end
