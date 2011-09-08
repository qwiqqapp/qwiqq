class CreatePressLinks < ActiveRecord::Migration
  def self.up
    create_table :press_links do |t|
      t.string :publication_name
      t.text   :article_title
      t.timestamp :published_at
      t.string :url

      t.timestamps
    end

    add_index :press_links, :published_at
  end

  def self.down
    drop_table :press_links
  end
end
