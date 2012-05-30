class AddCouponToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :coupon, :boolean, :default => false
  end
end
