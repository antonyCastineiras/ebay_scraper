class CreateEbayScrapes < ActiveRecord::Migration[5.0]
  def change
    create_table :ebay_scrapes do |t|
      t.string :search
      t.text :object

      t.timestamps
    end
  end
end
