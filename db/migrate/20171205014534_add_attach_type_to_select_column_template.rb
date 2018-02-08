class AddAttachTypeToSelectColumnTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :select_column_templates, :attachType, :string
  end
end
