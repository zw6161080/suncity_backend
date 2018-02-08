class CreateShiftEmployeeCountSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :shift_employee_count_settings do |t|
      t.integer :grade_tag
      t.integer :max_number
      t.integer :min_number

      t.date :date
      t.daterange :date_range
      t.integer :wday
      
      t.references :shift

      t.timestamps
    end
  end
end
