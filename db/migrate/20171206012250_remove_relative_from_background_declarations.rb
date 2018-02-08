class RemoveRelativeFromBackgroundDeclarations < ActiveRecord::Migration[5.0]
  def change
    remove_column :background_declarations, :have_any_relatives, :integer
    remove_column :background_declarations, :relative_criminal_record, :integer
    remove_column :background_declarations, :relative_business_relationship_with_suncity, :integer
  end
end
