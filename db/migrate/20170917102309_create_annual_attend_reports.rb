class CreateAnnualAttendReports < ActiveRecord::Migration[5.0]
  def change
    create_table :annual_attend_reports do |t|
      t.integer :department_id
      t.integer :user_id
      t.integer :year
      t.boolean :is_meet
      t.date :settlement_date
      t.decimal :money_hkd, precision: 15, scale: 2

      t.timestamps
    end
  end
end
