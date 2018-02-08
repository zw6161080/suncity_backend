class AddIndexToWelfareTemplates < ActiveRecord::Migration[5.0]
  def change
    add_index :welfare_templates, :template_chinese_name
    add_index :welfare_templates, :template_english_name
  end
end
