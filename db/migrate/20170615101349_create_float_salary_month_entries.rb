class CreateFloatSalaryMonthEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :float_salary_month_entries do |t|
      t.datetime :year_month
      t.string :status
      t.integer :employees_count

      t.timestamps
    end
  end
end
