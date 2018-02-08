class CreateSupervisorAssessments < ActiveRecord::Migration[5.0]
  def change
    create_table :supervisor_assessments do |t|
      t.string :region
      t.integer :user_id

      t.integer :questionnaire_template_id
      t.integer :questionnaire_id

      t.integer :employment_status
      t.integer :exam_mode

      t.integer :training_result
      t.integer :attendance_rate
      t.integer :score
      t.integer :assessment_status
      t.date :filled_in_date
      t.text :comment

      t.timestamps
    end
  end
end
