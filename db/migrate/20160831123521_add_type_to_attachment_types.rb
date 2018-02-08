class AddTypeToAttachmentTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :attachment_types, :type, :string
    AttachmentType.update_all(type: "ProfileAttachmentType")  
  end
end
