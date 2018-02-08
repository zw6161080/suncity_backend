class AddPreviewStatusToAttachment < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :preview_state, :string
    add_column :attachments, :preview_hash, :string
  end
end
