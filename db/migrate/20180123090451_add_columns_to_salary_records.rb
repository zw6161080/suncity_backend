class AddColumnsToSalaryRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_records, :service_award, :decimal, precision: 15, scale: 2
    add_column :salary_records, :internship_bonus, :decimal, precision: 15, scale: 2
    add_column :salary_records, :performance_award, :decimal, precision: 15, scale: 2
    add_column :salary_records, :special_tie_bonus, :decimal, precision: 15, scale: 2
  end
end
