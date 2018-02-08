class CreateDepartmentStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :department_statuses do |t|
      t.datetime :year_month
      t.integer :employees_on_duty
      t.integer :employees_left_this_month
      t.integer :employees_left_last_day
      t.timestamps
    end
  end
end
