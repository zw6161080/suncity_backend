class AddAttachmentIdToOnlineMaterials < ActiveRecord::Migration[5.0]
  def change
    add_column :online_materials, :attachment_id, :integer
  end
end
