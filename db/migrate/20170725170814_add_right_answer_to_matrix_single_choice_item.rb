class AddRightAnswerToMatrixSingleChoiceItem < ActiveRecord::Migration[5.0]
  def change
    add_column :matrix_single_choice_items, :right_answer, :integer
  end
end
