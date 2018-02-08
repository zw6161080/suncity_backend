class AddSalaryTemplateToSpecialAssessment < ActiveRecord::Migration[5.0]
  def change
    add_column :special_assessments, :salary_template, :jsonb
    add_column :special_assessments, :new_salary_template, :jsonb
    remove_column :special_assessments, :salary_template_id, :integer
  end
end
