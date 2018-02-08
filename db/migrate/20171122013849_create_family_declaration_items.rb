class CreateFamilyDeclarationItems < ActiveRecord::Migration[5.0]
  def change
    create_table :family_declaration_items do |t|
      t.string :relative_relation
      t.integer :user_id

      t.timestamps
    end
  end
end
