class CreateAppraisalForDepartments < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_for_departments do |t|
      t.references :appraisal, foreign_key: true, index: true
      t.references :department, foreign_key: true, index: true
      t.integer    :participator_amount_in_department
      t.decimal    :ave_total_appraisal_in_department, precision: 5, scale: 2

      t.timestamps
    end
  end
end
