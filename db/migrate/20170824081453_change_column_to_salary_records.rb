class ChangeColumnToSalaryRecords < ActiveRecord::Migration[5.0]
  def change
    rename_column :salary_records, :total_bonus_unit, :total_count_unit
  end
end
