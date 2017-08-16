class AddConditionToResult < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :condition, :string
  end
end
