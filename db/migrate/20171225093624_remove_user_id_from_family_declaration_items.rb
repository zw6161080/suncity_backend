class RemoveUserIdFromFamilyDeclarationItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :family_declaration_items, :user_id, :integer
  end
end
