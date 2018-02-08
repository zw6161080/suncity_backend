class CreateAssessmentQuestionnaires < ActiveRecord::Migration[5.0]
  def change
    create_table :assessment_questionnaires do |t|
      t.string :region
      t.references :questionnairable,
                   polymorphic: true,
                   index: { name: 'index_assess_ques_on_quesable_type_and_quesable_id' }

      t.timestamps
    end
  end
end
