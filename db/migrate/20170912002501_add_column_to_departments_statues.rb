class AddColumnToDepartmentsStatues < ActiveRecord::Migration[5.0]
  def change
    add_column :department_statuses, :department_id, :integer
    add_column :department_statuses, :float_salary_month_entry_id, :integer
  end
end
