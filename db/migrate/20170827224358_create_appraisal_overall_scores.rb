class CreateAppraisalOverallScores < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_overall_scores do |t|
      t.references :appraisal, foreign_key: true
      t.decimal :group_A_score, precision: 5, scale: 2
      t.decimal :group_B_score, precision: 5, scale: 2
      t.decimal :group_C_score, precision: 5, scale: 2
      t.decimal :group_D_score, precision: 5, scale: 2
      t.decimal :group_E_score, precision: 5, scale: 2
      t.timestamps
    end
  end
end
