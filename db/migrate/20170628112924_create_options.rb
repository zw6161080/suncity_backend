class CreateOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :options do |t|

      t.integer :choice_question_id
      t.integer :option_no
      t.string :description
      t.string :supplement

      t.timestamps
    end
  end
end
