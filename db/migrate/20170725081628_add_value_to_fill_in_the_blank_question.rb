class AddValueToFillInTheBlankQuestion < ActiveRecord::Migration[5.0]
  def change
    add_column :fill_in_the_blank_questions, :value, :integer
    add_column :fill_in_the_blank_questions, :score, :integer
    add_column :fill_in_the_blank_questions, :annotation, :text
    add_column :fill_in_the_blank_questions, :right_answer, :text
  end
end
