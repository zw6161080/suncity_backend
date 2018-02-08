class AddDepartmentIdToSelectColumnTemplates < ActiveRecord::Migration[5.0]
  def change
    add_column :select_column_templates, :department_id, :integer
  end
end
