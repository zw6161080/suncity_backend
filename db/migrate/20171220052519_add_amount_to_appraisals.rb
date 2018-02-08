class AddAmountToAppraisals < ActiveRecord::Migration[5.0]
  def change
    add_column :appraisals, :participator_department_amount, :integer
    add_column :appraisals, :ave_company_appraisal, :decimal, precision: 5, scale: 2
    add_column :appraisals, :ave_department_appraisal, :decimal, precision: 5, scale: 2
  end
end
