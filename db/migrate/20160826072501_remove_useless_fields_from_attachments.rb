class RemoveUselessFieldsFromAttachments < ActiveRecord::Migration[5.0]
  def change
    remove_column :attachments, :type
    remove_column :attachments, :profile_id
    remove_column :attachments, :profile_attachment_type_id
    remove_column :attachments, :description
    remove_column :attachments, :creater_id
  end
end
