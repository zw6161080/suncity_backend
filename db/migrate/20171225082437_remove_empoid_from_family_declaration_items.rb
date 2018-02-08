class RemoveEmpoidFromFamilyDeclarationItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :family_declaration_items, :empoid, :integer
    remove_column :family_declaration_items, :chinese_name, :string
  end
end
