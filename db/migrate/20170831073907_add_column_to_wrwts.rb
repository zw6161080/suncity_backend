class AddColumnToWrwts < ActiveRecord::Migration[5.0]
  def change
    add_column :wrwts, :airfare_type, :string
    add_column :wrwts, :airfare_count, :integer
  end
end
