class ChangeColumnToTrainingPapers < ActiveRecord::Migration[5.0]
  def change
    remove_column :training_papers , :questionnaire_template_id, :integer
    remove_column :training_papers , :questionnaire_id, :integer
  end
end
