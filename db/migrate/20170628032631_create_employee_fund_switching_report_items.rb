class CreateEmployeeFundSwitchingReportItems < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_fund_switching_report_items do |t|
      t.integer :user_id

      t.string :pension_fund_name_in_employer_contribution
      t.decimal :contribution_allocation_percentage_in_employer_contribution, precision: 10, scale: 2
      t.string :name_of_fund_to_be_redeemed_in_employer_contribution
      t.decimal :percentage_in_employer_contribution, precision: 10, scale: 2
      t.string :name_of_fund_to_be_allocated_in_employer_contribution

      t.string :pension_fund_name_in_employer_voluntary_contribution
      t.decimal :contribution_allocation_percentage_in_employer_voluntary_contri, precision: 10, scale: 2
      t.string :name_of_fund_to_be_redeemed_in_employer_voluntary_contribution
      t.decimal :percentage_in_employer_voluntary_contribution, precision: 10, scale: 2
      t.string :name_of_fund_to_be_allocated_in_employer_voluntary_contribution

      t.string :pension_fund_name_in_employee_contribution
      t.decimal :contribution_allocation_percentage_in_employee_contribution, precision: 10, scale: 2
      t.string :name_of_fund_to_be_redeemed_in_employee_contribution
      t.decimal :percentage_in_employee_contribution, precision: 10, scale: 2
      t.string :name_of_fund_to_be_allocated_in_employee_contribution

      t.string :pension_fund_name_in_employee_voluntary_contribution
      t.decimal :contribution_allocation_percentage_in_employee_voluntary_contri, precision: 10, scale: 2
      t.string :name_of_fund_to_be_redeemed_in_employee_voluntary_contribution
      t.decimal :percentage_in_employee_voluntary_contribution, precision: 10, scale: 2
      t.string :name_of_fund_to_be_allocated_in_employee_voluntary_contribution

      t.string :pension_fund_name_in_government_contribution
      t.decimal :contribution_allocation_percentage_in_government_contribution, precision: 10, scale: 2
      t.string :name_of_fund_to_be_redeemed_in_government_contribution
      t.decimal :percentage_in_government_contribution, precision: 10, scale: 2
      t.string :name_of_fund_to_be_allocated_in_government_contribution

      t.timestamps
    end
  end
end
