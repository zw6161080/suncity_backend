class AddFileNameToProfileAttachments < ActiveRecord::Migration[5.0]
  def change
    add_column :profile_attachments, :file_name, :string
  end
end
