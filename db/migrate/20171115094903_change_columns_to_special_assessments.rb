class ChangeColumnsToSpecialAssessments < ActiveRecord::Migration[5.0]
  def change
    remove_column :special_assessments, :creator_id, :integer
    add_column :special_assessments, :job_transfer_id, :integer
    rename_column :special_assessments, :salary_template, :salary_record
    rename_column :special_assessments, :new_salary_template, :new_salary_record
  end
end
