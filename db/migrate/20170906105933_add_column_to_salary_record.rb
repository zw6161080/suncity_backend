class AddColumnToSalaryRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_records, :region_bonus, :decimal, precision: 10, scale: 2
  end
end
