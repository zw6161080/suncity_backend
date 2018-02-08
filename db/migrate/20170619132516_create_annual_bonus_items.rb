class CreateAnnualBonusItems < ActiveRecord::Migration[5.0]
  def change
    create_table :annual_bonus_items do |t|
      t.references :user, foreign_key: true
      t.references :annual_bonus, foreign_key: true
      t.boolean :has_annual_incentive_payment
      t.decimal :annual_incentive_payment_hkd, precision: 15, scale: 2
      t.boolean :has_double_pay
      t.decimal :double_pay_mop, precision: 15, scale: 2
      t.boolean :has_year_end_bonus
      t.decimal :year_end_bonus_mop, precision: 15, scale: 2

      t.timestamps
    end
  end
end
