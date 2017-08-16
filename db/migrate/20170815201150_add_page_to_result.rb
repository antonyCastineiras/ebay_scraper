class AddPageToResult < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :page, :text
  end
end
