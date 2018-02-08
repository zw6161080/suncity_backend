class CreateWelfareRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :welfare_records do |t|
      t.string :change_reason
      t.datetime :welfare_begin
      t.datetime :welfare_end
      t.decimal :annual_leave, precision: 10, scale: 2
      t.decimal :sick_leave, precision: 10, scale: 2
      t.decimal :office_holiday, precision: 10, scale: 2
      t.integer :welfare_template_id
      t.string :holiday_type
      t.decimal :probation, precision: 10, scale: 2
      t.decimal :notice_period, precision: 10, scale: 2
      t.boolean :double_pay
      t.boolean :reduce_salary_for_sick
      t.boolean :provide_airfare
      t.boolean :provide_accommodation
      t.boolean :provide_uniform
      t.string :salary_composition
      t.string :over_time_salary
      t.string :force_holiday_make_up
      t.string :comment
      t.integer :user_id
      t.string :status
      t.timestamps
    end
  end
end
