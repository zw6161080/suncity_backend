class CreateAttachmentItems < ActiveRecord::Migration[5.0]
  def change
    create_table :attachment_items do |t|
      t.string :file_name
      t.integer :creator_id
      t.text :comment
      t.references :attachment, foreign_key: true
      t.references :attachable, polymorphic: true

      t.timestamps
    end
  end
end
