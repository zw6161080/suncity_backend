class CreateTrainingCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :training_courses do |t|
      t.string :region
      t.integer :user_id
      t.integer :transfer_position_apply_by_employee_id
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.string :explanation

      t.timestamps
    end
  end
end
