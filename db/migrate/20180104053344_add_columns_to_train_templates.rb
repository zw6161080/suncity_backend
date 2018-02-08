class AddColumnsToTrainTemplates < ActiveRecord::Migration[5.0]
  def change
    add_column :train_templates, :questionnaire_template_chinese_name, :string
    add_column :train_templates, :questionnaire_template_english_name, :string
    add_column :train_templates, :questionnaire_template_simple_chinese_name, :string
  end
end
