class AddAttachmentMissingSmsSentToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :attachment_missing_sms_sent, :boolean, default: false
  end
end
