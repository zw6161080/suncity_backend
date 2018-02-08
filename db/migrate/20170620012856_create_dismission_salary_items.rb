class CreateDismissionSalaryItems < ActiveRecord::Migration[5.0]
  def change
    create_table :dismission_salary_items do |t|
      t.references :user, foreign_key: true
      t.references :dimission, foreign_key: true

      t.decimal :base_salary_hkd, precision: 15, scale: 2
      t.decimal :benefits_hkd, precision: 15, scale: 2
      t.decimal :annual_incentive_hkd, precision: 15, scale: 2
      t.decimal :housing_benefits_hkd, precision: 15, scale: 2
      t.decimal :seniority_compensation_hkd, precision: 15, scale: 2
      t.decimal :dismission_annual_holiday_compensation_hkd, precision: 15, scale: 2
      t.decimal :dismission_inform_period_compensation, precision: 15, scale: 2

      t.timestamps
    end
  end
end
