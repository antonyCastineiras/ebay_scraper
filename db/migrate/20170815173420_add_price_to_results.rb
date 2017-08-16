class AddPriceToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :price, :float
  end
end
