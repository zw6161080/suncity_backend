class AddColumnToSalaryValues < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_values, :salary_column_id, :integer
  end
end
