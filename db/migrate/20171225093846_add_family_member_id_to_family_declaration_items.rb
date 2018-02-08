class AddFamilyMemberIdToFamilyDeclarationItems < ActiveRecord::Migration[5.0]
  def change
    add_column :family_declaration_items, :family_member_id, :integer
  end
end
