class AddCouponCountToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :coupon_count, :integer
  end
end
