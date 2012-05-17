class AddHasCouponToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :has_coupon, :boolean
  end
end
