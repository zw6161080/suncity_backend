class AddRelativeToBackgroundDeclarations < ActiveRecord::Migration[5.0]
  def change
    add_column :background_declarations, :have_any_relatives, :boolean
    add_column :background_declarations, :relative_criminal_record, :boolean
    add_column :background_declarations, :relative_business_relationship_with_suncity, :boolean
    add_column :family_declaration_items, :empoid, :integer
    add_column :family_declaration_items, :chinese_name, :string
  end
end
