class CreateCardAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :card_attachments do |t|
      t.string :category
      t.string :file_name
      t.string :operator
      t.text :comment
      t.integer :attachment_id
      t.references :card_profile, foreign_key: true

      t.timestamps
    end
  end
end
