class CreateSalaryRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :salary_records do |t|
      t.integer :user_id
      t.string :status
      t.string :change_reason
      t.datetime :salary_begin
      t.datetime :salary_end
      t.integer :salary_template_id
      t.decimal :basic_salary, precision: 10, scale: 2
      t.string :basic_salary_unit
      t.decimal :bonus, precision: 10, scale: 2
      t.string :bonus_unit
      t.decimal :attendance_award, precision: 10, scale: 2
      t.string :attendance_award_unit
      t.decimal :house_bonus, precision: 10, scale: 2
      t.string :house_bonus_unit
      t.string :total_bonus_unit
      t.decimal :new_year_bonus, precision: 10, scale: 2
      t.decimal :project_bonus, precision: 10, scale: 2
      t.decimal :product_bonus, precision: 10, scale: 2
      t.decimal :tea_bonus, precision: 10, scale: 2
      t.decimal :kill_bonus, precision: 10, scale: 2
      t.decimal :performance_bonus, precision: 10, scale: 2
      t.decimal :charge_bonus, precision: 10, scale: 2
      t.decimal :commission_bonus, precision: 10, scale: 2
      t.decimal :receive_bonus, precision: 10, scale: 2
      t.decimal :exchange_rate_bonus, precision: 10, scale: 2
      t.decimal :guest_card_bonus, precision: 10, scale: 2
      t.decimal :respect_bonus, precision: 10, scale: 2
      t.string :comment

      t.timestamps
    end
  end
end
