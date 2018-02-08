class AddColumnToMatrixSingleChoiceQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :matrix_single_choice_questions, :score_of_question, :decimal, precision: 5, scale: 2
  end
end
