class CreateAppraisalForUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_for_users do |t|
      t.references :appraisal, foreign_key: true, index: true
      t.references :appraisal_for_department, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.decimal    :ave_total_appraisal_self, precision: 5, scale: 2

      t.timestamps
    end
  end
end
