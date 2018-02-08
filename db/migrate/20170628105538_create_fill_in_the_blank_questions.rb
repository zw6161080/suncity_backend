class CreateFillInTheBlankQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :fill_in_the_blank_questions do |t|

      t.integer :questionnaire_id
      t.integer :questionnaire_template_id
      t.integer :order_no
      t.text :question
      t.text :answer
      t.boolean :is_required

      t.timestamps
    end
  end
end
