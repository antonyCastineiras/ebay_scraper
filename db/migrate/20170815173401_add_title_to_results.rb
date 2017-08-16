class AddTitleToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :title, :string
  end
end
