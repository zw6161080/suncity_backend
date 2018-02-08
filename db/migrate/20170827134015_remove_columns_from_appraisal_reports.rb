class RemoveColumnsFromAppraisalReports < ActiveRecord::Migration[5.0]
  def change
    drop_table :appraisal_reports do |t|
      t.references :user, index: true, foregin_key: true
      t.references :appraisal_participator, index: true, foreign_key: true
      t.references :appraisal_questionnaire, index: true, foreign_key: true
      t.jsonb      :questionnaire_score
      t.timestamps
    end

    create_table :appraisal_reports do |t|
      t.references :appraisal, index: true, foreign_key: true
      t.references :appraisal_participator, index: true, foreign_key: true
      t.decimal    :overall_score, precision: 5, scale: 2
      t.decimal    :superior_score, precision: 5, scale: 2
      t.decimal    :colleague_score, precision: 5, scale: 2
      t.decimal    :subordinate_score, precision: 5, scale: 2
      t.decimal    :self_score, precision: 5, scale: 2
      t.jsonb      :report_detail, null: false, default: '{}'
      t.timestamps
    end


  end
end
