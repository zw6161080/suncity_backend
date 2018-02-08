class AddColumnsToQuestionnaireQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :fill_in_the_blank_questions, :is_filled_in, :boolean
    add_column :matrix_single_choice_items, :is_filled_in, :boolean
    add_column :choice_questions, :is_filled_in, :boolean
  end
end
