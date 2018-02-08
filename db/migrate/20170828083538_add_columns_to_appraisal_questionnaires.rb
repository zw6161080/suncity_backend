class AddColumnsToAppraisalQuestionnaires < ActiveRecord::Migration[5.0]
  def change
    add_column :appraisal_questionnaires, :assess_type, :string
    add_column :appraisal_questionnaires, :final_score, :decimal, precision: 5, scale: 2
  end
end
