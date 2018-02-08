class CreateTrainingPapers < ActiveRecord::Migration[5.0]
  def change
    create_table :training_papers do |t|
      t.string :region
      t.integer :user_id

      t.integer :questionnaire_template_id
      t.integer :questionnaire_id

      t.integer :employment_status
      t.integer :exam_mode
      t.integer :score
      t.integer :attendance_rate
      t.integer :paper_status
      t.integer :correct_percentage
      t.date :filled_in_date
      t.date :latest_upload_date
      t.text :comment

      t.timestamps
    end
  end
end
