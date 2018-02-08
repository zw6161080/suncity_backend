class CreateStudentEvaluations < ActiveRecord::Migration[5.0]
  def change
    create_table :student_evaluations do |t|
      t.string :region
      t.integer :user_id

      t.integer :questionnaire_template_id
      t.integer :questionnaire_id

      t.integer :employment_status
      t.integer :training_type

      t.integer :lecturer_id
      t.integer :satisfaction
      t.integer :evaluation_status

      t.date :filled_in_date
      t.text :comment

      t.timestamps
    end
  end
end
