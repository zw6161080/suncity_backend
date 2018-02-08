class AddUserToFamilyDeclarationItems < ActiveRecord::Migration[5.0]
  def change
    add_column :family_declaration_items, :user_id, :integer
  end
end
