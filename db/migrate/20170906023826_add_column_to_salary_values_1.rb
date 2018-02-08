class AddColumnToSalaryValues1 < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_values, :salary_type, :string
  end
end
