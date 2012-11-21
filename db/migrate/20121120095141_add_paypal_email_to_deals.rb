class AddPaypalEmailToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :paypal_email, :string
  end
end
