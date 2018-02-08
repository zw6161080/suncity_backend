class ChangeColumnToSalaryRecords2 < ActiveRecord::Migration[5.0]
  def change
    remove_column :salary_records ,:house_bonus, :string
    add_column :salary_records, :house_bonus, :decimal, precision: 15, scale: 2
  end
end
