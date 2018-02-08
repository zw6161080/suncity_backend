class AddValueToMatrixSingleChoiceQuestion < ActiveRecord::Migration[5.0]
  def change
    add_column :matrix_single_choice_questions, :value, :integer
    add_column :matrix_single_choice_questions, :score, :integer
    add_column :matrix_single_choice_questions, :annotation, :text
  end
end
