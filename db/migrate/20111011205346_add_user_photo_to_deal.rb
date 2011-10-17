class AddUserPhotoToDeal < ActiveRecord::Migration
  def self.up
    add_column :deals, :user_photo, :string
    add_column :deals, :user_photo_2x, :string
    Deal.reset_column_information
    Deal.find_each do |d|
      d.user_photo = d.user.photo(:iphone_small)
      d.user_photo_2x = d.user.photo(:iphone_small_2x)
      d.save
    end
  end

  def self.down
  end
end
