class AddQuestionnaireQuestionnaireTemplateIdToTrainTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :train_templates, :questionnaire_template_id, :integer
  end
end
