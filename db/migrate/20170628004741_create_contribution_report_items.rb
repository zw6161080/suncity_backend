class CreateContributionReportItems < ActiveRecord::Migration[5.0]
  def change
    create_table :contribution_report_items do |t|
      t.integer :user_id
      t.datetime :year_month

      t.decimal :relevant_income, precision: 15, scale: 2
      t.decimal :employee_voluntary_contribution_percentage, precision: 15, scale: 2
      t.decimal :employee_voluntary_contribution_amount, precision: 15, scale: 2
      t.decimal :percentage_of_voluntary_contributions_of_members, precision: 15, scale: 2
      t.decimal :membership_voluntary_contributions_amount, precision: 15, scale: 2
      t.decimal :employer_contribution_percentage, precision: 15, scale: 2
      t.decimal :employer_contribution_count, precision: 15, scale: 2
      t.decimal :percentage_of_contribution_of_members, precision: 15, scale: 2
      t.decimal :percentage_of_contribution_of_governmment, precision:15, scale: 2
      t.decimal :count_of_contribution_of_governmment, precision:15, scale: 2

      t.timestamps
    end
  end
end
