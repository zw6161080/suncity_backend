class ChangeInformPeriodCompensationFieldInDismissionSalaryItem < ActiveRecord::Migration[5.0]
  def change
    remove_column :dismission_salary_items, :dismission_inform_period_compensation, :decimal, precision: 15, scale: 2
    add_column :dismission_salary_items, :dismission_inform_period_compensation_hkd, :decimal, precision: 15, scale: 2
  end
end
