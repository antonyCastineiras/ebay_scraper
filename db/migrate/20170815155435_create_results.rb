class CreateResults < ActiveRecord::Migration[5.0]
  def change
    create_table :results do |t|
      t.text :object
      t.references :ebay_scrape, foreign_key: true

      t.timestamps
    end
  end
end
