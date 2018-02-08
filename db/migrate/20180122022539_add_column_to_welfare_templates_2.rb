class AddColumnToWelfareTemplates2 < ActiveRecord::Migration[5.0]
  def change
    add_column :welfare_templates, :position_type, :string
    add_column :welfare_templates, :work_days_every_week, :integer, in: 5..6
  end
end
