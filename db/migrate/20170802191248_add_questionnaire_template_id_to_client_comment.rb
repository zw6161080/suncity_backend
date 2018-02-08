class AddQuestionnaireTemplateIdToClientComment < ActiveRecord::Migration[5.0]
  def change
    add_column :client_comments, :questionnaire_template_id, :integer
    add_column :client_comments, :questionnaire_id, :integer
  end
end
