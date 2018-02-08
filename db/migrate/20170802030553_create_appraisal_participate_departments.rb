class CreateAppraisalParticipateDepartments < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_participate_departments do |t|
      t.references :appraisal, foreign_key: true, index: true
      t.references :location, foreign_key: true, index: true
      t.references :department, foreign_key: true, index: true
      t.boolean :confirmed
      t.integer :participator_amount

      t.timestamps
    end
  end
end
