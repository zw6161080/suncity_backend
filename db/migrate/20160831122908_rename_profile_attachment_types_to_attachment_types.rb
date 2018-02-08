class RenameProfileAttachmentTypesToAttachmentTypes < ActiveRecord::Migration[5.0]
  def change
    rename_table :profile_attachment_types, :attachment_types
  end
end
