class CreateAnnualWorkAwards < ActiveRecord::Migration[5.0]
  def change
    create_table :annual_work_awards do |t|
      t.string :award_chinese_name, null: false
      t.string :award_english_name, null: false
      t.string :begin_date, null: false
      t.string :end_date, null: false
      t.integer :num_of_award, null: false
      t.integer :has_paid, null: false, default: 0
      t.timestamps
    end
  end
end
