class RemoveNameNumberFromFamilyDeclarationItems < ActiveRecord::Migration[5.0]
  def change
    add_column :family_declaration_items, :relative_name, :string
    add_column :family_declaration_items, :relative_contact_number, :integer
    remove_column :family_declaration_items, :relative_name, :string
    remove_column :family_declaration_items, :relative_contact_number, :integer
  end
end
