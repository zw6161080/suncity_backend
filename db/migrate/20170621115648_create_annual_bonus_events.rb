class CreateAnnualBonusEvents < ActiveRecord::Migration[5.0]
  def change
    remove_reference :annual_bonus_items, :annual_bonus

    drop_table :annual_bonus do |t|
      t.string :chinese_name
      t.string :english_name
      t.datetime :begin_date
      t.datetime :end_date
      t.decimal :annual_incentive_payment_hkd, precision: 15, scale: 2
      t.string :year_end_bonus_rule
      t.decimal :year_end_bonus_mop, precision: 15, scale: 2
      t.string :settlement_type
      t.datetime :settlement_salary_year_month
      t.datetime :settlement_date

      t.timestamps
    end

    create_table :annual_bonus_events do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.datetime :begin_date
      t.datetime :end_date
      t.decimal :annual_incentive_payment_hkd, precision: 15, scale: 2
      t.string :year_end_bonus_rule
      t.decimal :year_end_bonus_mop, precision: 15, scale: 2
      t.string :settlement_type
      t.datetime :settlement_salary_year_month
      t.datetime :settlement_date

      t.timestamps
    end

    add_reference :annual_bonus_items, :annual_bonus_event
  end
end
