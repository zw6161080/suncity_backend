class AddFilledAttachmentTypesToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :filled_attachment_types, :jsonb
  end
end
