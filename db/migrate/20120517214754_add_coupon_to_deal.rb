class AddCouponToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :coupon, :boolean
  end
end
