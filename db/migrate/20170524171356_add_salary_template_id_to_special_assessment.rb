class AddSalaryTemplateIdToSpecialAssessment < ActiveRecord::Migration[5.0]
  def change
    add_column :special_assessments, :salary_template_id, :integer
  end
end
