class CreateQuestionnaireTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :questionnaire_templates do |t|
      t.string :region
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.string :template_type
      t.text :template_introduction
      t.integer :questionnaires_count, default: 0

      t.integer :creator_id
      t.text :comment

      t.timestamps
    end
  end
end
