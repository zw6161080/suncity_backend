class CreateGrantTypeDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :grant_type_details do |t|
      t.integer :user_id
      t.boolean :add_basic_salary
      t.integer :basic_salary_time
      t.boolean :add_bonus
      t.integer :bonus_time
      t.boolean :add_attendance_bonus
      t.integer :attendance_bonus_time
      t.boolean :add_fixed_award
      t.decimal :fixed_award_mop, precision: 15, scale: 2
      t.integer :annual_award_report_id
      t.timestamps
    end
  end
end
