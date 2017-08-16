class AddFormatToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :format, :string
  end
end
