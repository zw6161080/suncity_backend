class AddWelfareTemplateEffectedToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :welfare_template_effected, :boolean, default: true, index: true
  end
end
