class AddHrefToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :href, :string
  end
end
