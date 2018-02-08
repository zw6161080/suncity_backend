class CreateMatrixSingleChoiceItems < ActiveRecord::Migration[5.0]
  def change
    create_table :matrix_single_choice_items do |t|

      t.integer :matrix_single_choice_question_id
      t.integer :item_no
      t.text :question
      t.integer :score
      t.boolean :is_required
      t.timestamps
    end
  end
end
