class CreatePaidSickLeaveAwards < ActiveRecord::Migration[5.0]
  def change
    create_table :paid_sick_leave_awards do |t|
      t.string :award_chinese_name, null: false
      t.string :award_english_name, null: false
      t.string :begin_date, null: false
      t.string :end_date, null: false
      t.string :due_date, null: false
      t.integer :has_offered, null: false, default: 0
      t.timestamps
    end
  end
end
