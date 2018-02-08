class CreateTrainTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :train_templates do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :courses_number
      t.string :teaching_form
      t.integer :train_template_type_id
      t.decimal :training_credits, precision: 15, scale: 2
      t.integer :online_or_offline_training
      t.integer :limit_number
      t.decimal :course_total_time ,precision: 15, scale: 2
      t.decimal :course_total_count, precision: 15, scale: 2
      t.string :trainer
      t.string :language_of_training
      t.string :place_of_training
      t.string :contact_person_of_training
      t.string :course_series
      t.string :course_certificate
      t.string :introduction_of_trainee
      t.string :introduction_of_course
      t.string :goal_of_learning
      t.string :content_of_course
      t.string :goal_of_course
      t.integer :assessment_method
      t.decimal :test_scores_not_less_than, precision: 15, scale: 2
      t.integer :exam_format
      t.integer :exam_template_id
      t.decimal :comprehensive_attendance_not_less_than, precision: 15, scale: 2
      t.decimal :comprehensive_attendance_and_test_scores_not_less_than, precision: 15, scale: 2
      t.decimal :attendance_scores_percentage, precision: 15, scale: 2
      t.string :notice
      t.string :comment
      t.integer :creator_id

      t.timestamps
    end
  end
end
