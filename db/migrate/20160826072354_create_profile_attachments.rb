class CreateProfileAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_attachments do |t|
      t.integer :profile_id
      t.integer :profile_attachment_type_id
      t.integer :attachment_id
      t.text :description
      t.integer :creater_id

      t.timestamps
    end
  end
end
