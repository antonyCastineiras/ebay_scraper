class AddShippingToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :shipping, :float
  end
end
