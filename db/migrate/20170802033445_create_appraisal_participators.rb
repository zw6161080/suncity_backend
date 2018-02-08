class CreateAppraisalParticipators < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_participators do |t|
      t.references :appraisal, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.references :department, foreign_key: true, index: true

      t.integer :appraisal_grade

      t.integer :times_assessing_others
      t.integer :times_assessed_by_superior
      t.integer :times_assessed_by_colleague
      t.integer :times_assessed_by_subordinate

      t.timestamps
    end
  end
end
