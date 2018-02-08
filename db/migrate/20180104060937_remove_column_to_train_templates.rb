class RemoveColumnToTrainTemplates < ActiveRecord::Migration[5.0]
  def change
    remove_column :train_templates, :questionnaire_template_id, :integer
  end
end
