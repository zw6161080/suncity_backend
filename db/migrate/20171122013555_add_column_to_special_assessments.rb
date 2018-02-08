class AddColumnToSpecialAssessments < ActiveRecord::Migration[5.0]
  def change
    add_column :special_assessments, :salary_calculation, :string
  end
end
