class AddColumnToFinalLists < ActiveRecord::Migration[5.0]
  def change
    add_column :final_lists, :comment, :string
  end
end
