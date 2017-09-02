class AddAveragePriceOfResultsToEbayScrapes < ActiveRecord::Migration[5.0]
  def change
    add_column :ebay_scrapes, :average_price_of_results, :float
  end
end
