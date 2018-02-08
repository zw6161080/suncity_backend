class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.string :type
      t.integer :profile_id
      t.integer :profile_attachment_type_id
      t.string :seaweed_hash
      t.string :file_name
      t.text :description

      t.timestamps
    end
  end
end
