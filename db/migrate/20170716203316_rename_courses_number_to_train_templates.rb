class RenameCoursesNumberToTrainTemplates < ActiveRecord::Migration[5.0]
  def change
   rename_column :train_templates, :courses_number, :course_number
  end
end
