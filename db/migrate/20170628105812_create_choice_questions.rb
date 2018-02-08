class CreateChoiceQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :choice_questions do |t|

      t.integer :questionnaire_id
      t.integer :questionnaire_template_id
      t.integer :order_no
      t.text :question
      t.integer :answer, array: true, default: []
      t.boolean :is_multiple
      t.boolean :is_required

      t.timestamps
    end
  end
end
