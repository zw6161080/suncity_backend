class CreateMyAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :my_attachments do |t|
      t.string :status
      t.decimal :download_process, precision: 15, scale: 2
      t.string :file_name
      t.integer :attachment_id
      t.integer :user_id
      t.timestamps
    end
  end
end
