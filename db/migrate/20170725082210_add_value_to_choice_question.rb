class AddValueToChoiceQuestion < ActiveRecord::Migration[5.0]
  def change
    add_column :choice_questions, :value, :integer
    add_column :choice_questions, :score, :integer
    add_column :choice_questions, :annotation, :text
    add_column :choice_questions, :right_answer, :integer, array: true, default: []
  end
end
