class RemoveColumnToSalaryRecord < ActiveRecord::Migration[5.0]
  def change
    remove_column :salary_records, :basic_salary_unit, :string
    remove_column :salary_records, :bonus_unit, :string
    remove_column :salary_records, :house_bonus_unit, :string
    remove_column :salary_records, :attendance_award_unit, :string
    remove_column :salary_records, :total_count_unit, :string
  end
end
