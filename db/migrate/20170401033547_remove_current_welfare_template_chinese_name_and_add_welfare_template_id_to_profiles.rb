class RemoveCurrentWelfareTemplateChineseNameAndAddWelfareTemplateIdToProfiles < ActiveRecord::Migration[5.0]
  def change
    remove_column :profiles, :current_welfare_template_chinese_name, :string
    add_column :profiles, :current_welfare_template_id, :integer
  end
end
