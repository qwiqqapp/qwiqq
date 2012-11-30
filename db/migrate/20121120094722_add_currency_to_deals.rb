class AddCurrencyToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :currency, :string
  end
end
