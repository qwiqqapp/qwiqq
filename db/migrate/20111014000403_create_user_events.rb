class CreateUserEvents < ActiveRecord::Migration
  def self.up
    create_table :user_events do |t|
      t.references :user, :null => false
      t.references :comment
      t.references :like
      t.references :share
      t.references :relationship

      t.references :deal
      t.string :deal_name

      t.references :created_by, :null => false
      t.string :created_by_photo, :null => false
      t.string :created_by_photo_2x, :null => false
      t.string :created_by_username, :null => false

      t.string :event_type, :null => false
      t.text :metadata
      t.timestamps
    end
  end

  def self.down
    drop_table :user_events
  end
end
