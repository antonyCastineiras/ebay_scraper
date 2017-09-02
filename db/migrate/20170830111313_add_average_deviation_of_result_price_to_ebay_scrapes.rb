class AddAverageDeviationOfResultPriceToEbayScrapes < ActiveRecord::Migration[5.0]
  def change
    add_column :ebay_scrapes, :average_deviation_of_result_price, :float
  end
end
