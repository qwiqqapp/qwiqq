class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.references :user, :null => false
      t.string :service, :null => false
      t.string :email
      t.datetime :created_at
      t.datetime :delivered_at
    end
  end

  def self.down
    drop_table :invitations
  end
end
