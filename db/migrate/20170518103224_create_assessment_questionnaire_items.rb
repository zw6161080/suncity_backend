class CreateAssessmentQuestionnaireItems < ActiveRecord::Migration[5.0]
  def change
    create_table :assessment_questionnaire_items do |t|
      t.string :region
      t.integer :assessment_questionnaire_id

      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name

      t.string :group_chinese_name
      t.string :group_english_name
      t.string :group_simple_chinese_name

      t.integer :order_no
      t.integer :score
      t.string :explain

      t.timestamps
    end
  end
end
