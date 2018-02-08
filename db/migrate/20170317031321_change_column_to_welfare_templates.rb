class ChangeColumnToWelfareTemplates < ActiveRecord::Migration[5.0]
  def change
    change_column :welfare_templates, :office_holiday, :float, null: false
  end
end
