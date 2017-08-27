class AddMaxNumberOfResultsToEbayScrape < ActiveRecord::Migration[5.0]
  def change
    add_column :ebay_scrapes, :max_number_of_results, :integer, default: 50
  end
end
