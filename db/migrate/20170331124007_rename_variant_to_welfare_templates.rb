class RenameVariantToWelfareTemplates < ActiveRecord::Migration[5.0]
  def change
    rename_column :welfare_templates, :variant, :double_pay
  end
end
