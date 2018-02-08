class CreateMatrixSingleChoiceQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :matrix_single_choice_questions do |t|

      t.integer :questionnaire_id
      t.integer :questionnaire_template_id
      t.integer :order_no
      t.text :title
      t.integer :max_score

      t.timestamps
    end
  end
end
