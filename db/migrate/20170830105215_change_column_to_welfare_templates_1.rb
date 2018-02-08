class ChangeColumnToWelfareTemplates1 < ActiveRecord::Migration[5.0]
  def change
    remove_column :welfare_templates, :salary_composition, :boolean
    add_column :welfare_templates, :salary_composition, :string
  end
end
