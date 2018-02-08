class AddCurrentWelfareTemplateChineseNameToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :current_welfare_template_chinese_name, :string
    add_column :profiles, :current_template_type, :integer
  end
end
