class AddForSaleOnPaypalToUsers < ActiveRecord::Migration
  def change
    add_column :deals, :for_sale_on_paypal, :boolean, :default => false
  end
end
