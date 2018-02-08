class AddTemplateSimpleChineseNameToWelfareTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :welfare_templates, :template_simple_chinese_name, :string
  end
end
