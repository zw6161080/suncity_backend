class CreateLocationDepartmentStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :location_department_statuses do |t|
      t.datetime :year_month
      t.integer :employees_on_duty
      t.integer :employees_left_this_month
      t.integer :employees_left_last_day
      t.integer :location_id
      t.integer :department_id
      t.integer :float_salary_month_entry_id
      t.timestamps
    end
  end
end
