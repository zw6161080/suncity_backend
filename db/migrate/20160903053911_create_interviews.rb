class CreateInterviews < ActiveRecord::Migration[5.0]
  def change
    create_table :interviews do |t|
      t.integer :applicant_position_id
      t.string :time
      t.text :comment
      t.integer :result, default: 0
      t.integer :score, default: 0
      t.text :evaluation
      t.integer :need_again, default: 0

      t.timestamps
    end
  end
end
